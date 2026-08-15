local json = require("cjson/json")
local REQUEST_TYPE = {
	GET = 1,
	POST = 2
}
local REQUEST_SYSTEM = {
	COMMON = 1
}
local Token_Invalid_Code_List = {
	-3,
	-4,
	-5,
	-6
}
local RETRY_COUNT = 3
local ERROR_TYPE = {
	Invalid_Token = "Invalid_Token",
	TimeOut = "TimeOut",
	Unknown = "UnKnown"
}
local M = {
	RequestMap = {
		UserProfile = {
			url = "/social_media/api/user/profile?{viewRoleId}",
			type = REQUEST_TYPE.GET
		},
		MomentRecommendList = {
			url = "/social_media/api/moment/recc_list?{page}&{pageSize}&{menuTuiteType}",
			type = REQUEST_TYPE.GET
		},
		MomentFollowList = {
			url = "/social_media/api/moment/follow_list?{page}&{pageSize}",
			type = REQUEST_TYPE.GET
		},
		MomentDetail = {
			url = "/social_media/api/moment/detail?{momentId}",
			type = REQUEST_TYPE.GET
		},
		MomentLike = {
			url = "/social_media/api/moment/like",
			type = REQUEST_TYPE.POST,
			bodyParamList = {
				"momentId"
			}
		},
		MomentCancelLike = {
			url = "/social_media/api/moment/cancel_like",
			type = REQUEST_TYPE.POST,
			bodyParamList = {
				"momentId"
			}
		},
		MomentCollectList = {
			url = "/social_media/api/moment/collect_list?{categoryId}&{page}&{pageSize}",
			type = REQUEST_TYPE.GET
		},
		MomentCollect = {
			url = "/social_media/api/moment/collect",
			type = REQUEST_TYPE.POST,
			bodyParamList = {
				"momentId"
			}
		},
		MomentCancelCollect = {
			url = "/social_media/api/moment/cancel_collect",
			type = REQUEST_TYPE.POST,
			bodyParamList = {
				"momentId"
			}
		},
		CommentAdd = {
			url = "/social_media/api/comment/add",
			type = REQUEST_TYPE.POST,
			bodyParamList = {
				"momentId",
				"text"
			}
		},
		CommentCancelLike = {
			url = "/social_media/api/comment/cancel_like",
			type = REQUEST_TYPE.POST,
			bodyParamList = {
				"commentId"
			}
		},
		CommentDelete = {
			url = "/social_media/api/comment/delete",
			type = REQUEST_TYPE.POST,
			bodyParamList = {
				"commentId"
			}
		},
		CommentLike = {
			url = "/social_media/api/comment/like",
			type = REQUEST_TYPE.POST,
			bodyParamList = {
				"commentId"
			}
		},
		CommentList = {
			url = "/social_media/api/comment/list?{momentId}&{page}&{pageSize}",
			type = REQUEST_TYPE.GET
		},
		MomentFollow = {
			url = "/social_media/api/follow/add",
			type = REQUEST_TYPE.POST,
			bodyParamList = {
				"targetId"
			}
		},
		MomentFollowDelete = {
			url = "/social_media/api/follow/delete",
			type = REQUEST_TYPE.POST,
			bodyParamList = {
				"targetId"
			}
		},
		TrendList = {
			url = "/social_media/api/trend/list?{areaId}&{page}&{pageSize}",
			type = REQUEST_TYPE.GET
		},
		TrendRandom = {
			url = "/social_media/api/trend/list?{areaId}",
			type = REQUEST_TYPE.GET
		},
		MomentListByTopic = {
			url = "/social_media/api/moment/list_by_topic?{topicId}&{page}&{pageSize}",
			type = REQUEST_TYPE.GET
		}
	}
}

function M.Start(request, args)
	if not request then
		print_error("http request undefined")

		return
	end

	args = args or {}
	local baseUrl = gCS.LuaUtils.GetGraffitoUrl()
	local url = ("%s%s"):format(baseUrl, request.url)

	local function onResponse(ret, content, code)
		M.HandleResponse({
			request = request,
			requestUrl = url,
			requestArgs = args,
			responseResult = ret,
			responseContent = content,
			responseCode = code
		})
	end

	if request.type == REQUEST_TYPE.POST then
		local bodyParams = {}

		if request.bodyParamList then
			for _, param in ipairs(request.bodyParamList) do
				bodyParams[param] = args[param]
			end
		end

		bodyParams.roleId = M.GetNumberRoleId()
		bodyParams.skey = M.GetSKey()
		local bodyContent = json.encode(bodyParams)

		gCS.LuaUtils.HttpPost(url, bodyContent, onResponse)
	elseif request.type == REQUEST_TYPE.GET then
		url = M.ReplaceUrlParams(url, request.system, args)

		gCS.LuaUtils.HttpGet(url, onResponse)
	end
end

function M.HandleResponse(args)
	local responseResult = args.responseResult
	local responseContent = args.responseContent
	local successCallback = args.requestArgs and args.requestArgs.successCallback
	local request = args.request

	if responseResult then
		local responseInfo = json.decode(responseContent)

		if responseInfo.code == 0 then
			local data = responseInfo.data

			if successCallback then
				successCallback(data)
			end

			gMessageManager:SendMessage(gEventConstants.ON_COMMON_REQUEST_SUCCESS, {
				request = request,
				data = data
			})

			return
		end
	end

	M.ReStartRequest(args)
end

function M.ReStartRequest(args)
	local responseContent = args.responseContent
	local responseCode = args.responseCode
	local requestUrl = args.requestUrl
	local failCallback = args.requestArgs and args.requestArgs.failCallback
	local request = args.request
	local requestArgs = args.requestArgs
	requestArgs = requestArgs or {}
	requestArgs.retryCount = requestArgs.retryCount or RETRY_COUNT

	if requestArgs.retryCount <= 0 then
		print_error(("%s url:%s, responseContent:%s, responseCode:%s"):format(ERROR_TYPE[requestArgs.errorType], requestUrl, responseContent, responseCode))

		local callbackInfo = {
			request = request,
			responseContent = responseContent,
			requestArgs = requestArgs
		}

		if failCallback then
			failCallback(callbackInfo)
		end

		gMessageManager:SendMessage(gEventConstants.ON_COMMON_REQUEST_FAIL, callbackInfo)
	else
		coroutine.start(function ()
			coroutine.step()

			requestArgs.retryCount = requestArgs.retryCount - 1
			local responseInfo = responseContent and json.decode(responseContent)
			local isTokenInValid = string.is_null_or_empty(M.GetSKey()) or responseInfo and table.find(Token_Invalid_Code_List, responseInfo.code)

			if isTokenInValid then
				gSKeyManager:QuerySkey(false, false, function ()
					requestArgs.errorType = ERROR_TYPE.Invalid_Token

					M.Start(request, requestArgs)
				end)
			else
				if responseCode == 0 then
					requestArgs.errorType = ERROR_TYPE.TimeOut
				end

				M.Start(request, requestArgs)
			end
		end)
	end
end

function M.ReplaceUrlParams(url, system, params)
	system = system or REQUEST_SYSTEM.COMMON
	params = params or {}

	if system == REQUEST_SYSTEM.COMMON then
		local separator = url:find("?") and "&" or "?"
		url = ("%s%s{roleId}&{skey}"):format(url, separator)
		params.skey = params.skey or M.GetSKey()
		params.roleId = params.roleId or M.GetPlayerRoleId()
	end

	local result = url:gsub("([&?]?){(.-)}(&?)", function (prefix, key, suffix)
		if params[key] then
			return (prefix == "?" and "?" or "&") .. key .. "=" .. tostring(params[key]) .. (suffix == "&" and "" or "")
		else
			return ""
		end
	end)
	result = result:gsub("&+", "&")
	result = result:gsub("%?&", "?")
	result = result:gsub("[?&]$", "")

	return result
end

function M.GetPlayerRoleId()
	return ulong.tostring(gPlayerManager.infoLogin.bindData.pid)
end

function M.GetNumberRoleId()
	local roleId = M.GetPlayerRoleId()

	return tonumber(roleId)
end

function M.GetSKey()
	return gSKeyManager:GetCachedSKey()
end

gCommonRequestUtils = M
