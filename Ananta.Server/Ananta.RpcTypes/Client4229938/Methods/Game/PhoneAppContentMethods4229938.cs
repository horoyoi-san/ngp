using Ananta.SDK.Serialization;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract(Inline = true)]
internal sealed class AskChangeHackerName4229938
{
    public string name = string.Empty;
}

[UxContract(Inline = true)]
internal sealed class AskReadHackerNewPost4229938
{
    public uint postId;
}

[UxContract(Inline = true)]
internal sealed class AskAcceptHackerPostTask4229938
{
    public uint postId;
}

[UxContract(Inline = true)]
internal sealed class SyncHackerJobInfo4229938
{
    public Auto.SpiritHackerJobInfo hackerJobInfo = new();
}

[UxContract(Inline = true)]
internal sealed class SyncPoliceFakeFileInfo4229938
{
    public uint spiritId;
    public Auto.PoliceFakeFileInfo policeFakeFileInfo = new();
}
