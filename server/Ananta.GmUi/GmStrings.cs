namespace AnantaTestGameServer;

public static class GmStrings
{
    /// <summary>
    /// Returns a full &lt;script&gt; block implementing the i18n system with cookie-based
    /// language persistence, a translations dictionary, and DOM auto-application.
    /// </summary>
    public static string GetI18nScript()
    {
        return """
<script>
function getCookie(n) {
  var cs = document.cookie.split(';');
  for (var i = 0; i < cs.length; i++) {
    var c = cs[i];
    while (c.charAt(0) === ' ') c = c.substring(1);
    if (c.indexOf(n + '=') === 0) return c.substring(n.length + 1);
  }
  return '';
}
function setCookie(n, v, d) {
  var e = '';
  if (d) { var dt = new Date(); dt.setTime(dt.getTime() + d * 864e5); e = ';expires=' + dt.toUTCString(); }
  document.cookie = n + '=' + v + e + ';path=/';
}
var T = {
  'lang': {en:'Language', ru:'Язык', zh:'语言', ja:'言語', pt:'Idioma'},
  'backToMenu': {en:'← Back to Menu', ru:'← Назад в меню', zh:'← 返回菜单', ja:'← メニューに戻る', pt:'← Voltar ao Menu'},
  'statusResults': {en:'Status & Results', ru:'Статус и результаты', zh:'状态与结果', ja:'ステータスと結果', pt:'Status e Resultados'},
  'waiting': {en:'Waiting...', ru:'Ожидание...', zh:'等待操作...', ja:'待機中...', pt:'Aguardando...'},
  'refreshStatus': {en:'Refresh Status', ru:'Обновить', zh:'刷新状态', ja:'ステータス更新', pt:'Atualizar Status'},
  'gmOperations': {en:'GM Operations', ru:'GM операции', zh:'GM 操作', ja:'GM操作', pt:'Operações GM'},
  'requesting': {en:'Requesting...', ru:'Запрос...', zh:'请求中:', ja:'リクエスト中:', pt:'Solicitando:'},
  'addWeapon': {en:'Add Weapon', ru:'Добавить оружие', zh:'添加武器', ja:'武器を追加', pt:'Adicionar Arma'},
  'menuTitle': {en:'GM Tools Menu', ru:'Меню GM', zh:'GM工具菜单', ja:'GMツールメニュー', pt:'Menu GM'},
  'vehicleControl': {en:'Vehicle Control', ru:'Управление транспортом', zh:'载具控制', ja:'乗り物コントロール', pt:'Controle de Veículos'},
  'vehicleDesc': {en:'Spawn, summon, and manage vehicles', ru:'Спавн и управление транспортом', zh:'生成、召唤和管理载具', ja:'乗り物の生成・召喚・管理', pt:'Gerar, invocar e gerenciar veículos'},
  'characterSwitch': {en:'Character Switch', ru:'Смена персонажа', zh:'角色切换', ja:'キャラクター切替', pt:'Troca de Personagem'},
  'characterDesc': {en:'Switch between 19 playable characters', ru:'Переключение между 19 персонажами', zh:'切换19个可玩角色', ja:'19人のプレイアブルキャラを切替', pt:'Alternar entre 19 personagens'},
  'weaponsPanel': {en:'Weapons Panel', ru:'Панель оружия', zh:'武器面板', ja:'武器パネル', pt:'Painel de Armas'},
  'weaponsDesc': {en:'Manage character weapons', ru:'Управление оружием', zh:'管理角色武器', ja:'キャラの武器を管理', pt:'Gerenciar armas do personagem'},
  'npcPanel': {en:'NPC Panel', ru:'Панель NPC', zh:'NPC面板', ja:'NPCパネル', pt:'Painel NPC'},
  'npcDesc': {en:'Spawn and manage NPCs', ru:'Спавн и управление NPC', zh:'生成和管理NPC', ja:'NPCの生成と管理', pt:'Gerar e gerenciar NPCs'},
  'weatherControl': {en:'Weather Control', ru:'Управление погодой', zh:'天气控制', ja:'天気コントロール', pt:'Controle do Clima'},
  'weatherDesc': {en:'Change weather conditions', ru:'Изменить погоду', zh:'改变天气状况', ja:'天気を変更する', pt:'Mudar condições climáticas'},
  'timeControl': {en:'Time Control', ru:'Управление временем', zh:'时间控制', ja:'時間コントロール', pt:'Controle do Tempo'},
  'timeDesc': {en:'Set game time to any hour', ru:'Установить любое время', zh:'设置游戏时间', ja:'ゲーム時間を設定', pt:'Definir hora do jogo'},
  'teleport': {en:'Teleport', ru:'Телепорт', zh:'传送', ja:'テレポート', pt:'Teletransporte'},
  'teleportDesc': {en:'Teleport to any coordinates', ru:'Телепорт на координаты', zh:'传送到任意坐标', ja:'任意の座標にテレポート', pt:'Teleportar para coordenadas'},
  'player': {en:'Player', ru:'Игрок', zh:'玩家', ja:'プレイヤー', pt:'Jogador'},
  'playerDesc': {en:'HP, buffs, revive, attributes', ru:'HP, баффы, возрождение', zh:'生命、增益、复活、属性', ja:'HP・バフ・復活・属性', pt:'HP, buffs, reviver, atributos'},
  'items': {en:'Items', ru:'Предметы', zh:'物品', ja:'アイテム', pt:'Itens'},
  'itemsDesc': {en:'Add items, money, fashions', ru:'Добавить предметы и деньги', zh:'添加物品、金钱、时装', ja:'アイテム・お金・时装を追加', pt:'Adicionar itens, dinheiro, modas'},
  'quests': {en:'Quests', ru:'Квесты', zh:'任务', ja:'クエスト', pt:'Missões'},
  'questsDesc': {en:'Accept, submit, fail, unlock all', ru:'Принять, сдать, провалить', zh:'接受、提交、失败、解锁', ja:'受注・提出・失敗・全解放', pt:'Aceitar, entregar, falhar, desbloquear'},
  'spawn': {en:'Spawn', ru:'Спавн', zh:'生成', ja:'スポーン', pt:'Spawn'},
  'spawnDesc': {en:'Spawn enemies and NPCs', ru:'Спавн врагов и NPC', zh:'生成敌人和NPC', ja:'敵とNPCをスポーン', pt:'Gerar inimigos e NPCs'},
  'debug': {en:'Debug', ru:'Отладка', zh:'调试', ja:'デバッグ', pt:'Depurar'},
  'debugDesc': {en:'Free skill, cooldowns, durability', ru:'Свободные навыки, кулдауны', zh:'自由技能、冷却、耐久', ja:'スキル自由・クールダウン・耐久', pt:'Skill livre, cooldowns, durabilidade'},
  'world': {en:'World', ru:'Мир', zh:'世界', ja:'ワールド', pt:'Mundo'},
  'worldDesc': {en:'Fog, reputation, spirits, vehicles', ru:'Туман, репутация, духи', zh:'迷雾、声望、精灵、载具', ja:'霧・評判・スピリット・乗り物', pt:'Névoa, reputação, espíritos, veículos'},
  'rpcDump': {en:'RPC Dump', ru:'RPC дамп', zh:'RPC转储', ja:'RPCダンプ', pt:'Dump RPC'},
  'rpcDumpDesc': {en:'View/export unhandled RPCs', ru:'Просмотр необработанных RPC', zh:'查看/导出未处理RPC', ja:'未処理RPCの表示/エクスポート', pt:'Ver/exportar RPCs não tratados'},
  'sessions': {en:'Sessions', ru:'Сессии', zh:'会话', ja:'セッション', pt:'Sessões'},
  'sessionsDesc': {en:'Track game client sessions', ru:'Отслеживание сессий', zh:'追踪游戏客户端会话', ja:'ゲームクライアントセッション追跡', pt:'Rastrear sessões do cliente'},
  'transit': {en:'Transit Control', ru:'Управление метро', zh:'地铁控制', ja:'地下鉄コントロール', pt:'Controle de Metrô'},
  'transitDesc': {en:'Toggle metro lines 1-24, set trains/line, resync', ru:'Переключение линий метро 1-24, настройка поездов', zh:'切换地铁线路1-24，设置每线列车数，重新同步', ja:'メトロ路線1-24の切替・列車数設定・同期', pt:'Alternar linhas de metrô 1-24, definir trens/linha, ressincronizar'},
  'vehicleTitle': {en:'Ananta GM Vehicle Tool', ru:'GM Инструмент транспорта', zh:'GM载具操作台', ja:'GM乗り物ツール', pt:'Ferramenta GM de Veículos'},
  'vehicleSub': {en:'Local GM vehicle tool, port {0}. Use after entering game.', ru:'Локальный GM инструмент, порт {0}', zh:'本地GM载具操作台，端口 {0}', ja:'ローカルGM乗り物ツール、ポート {0}', pt:'Ferramenta GM local, porta {0}'},
  'vehicleSelect': {en:'Vehicle Selection', ru:'Выбор транспорта', zh:'载具选择', ja:'乗り物選択', pt:'Seleção de Veículo'},
  'searchOrEnter': {en:'Search or enter Config ID', ru:'Поиск или введите ID', zh:'搜索或直接输入 Config ID', ja:'検索またはID入力', pt:'Pesquisar ou inserir ID'},
  'seat': {en:'Seat', ru:'Сиденье', zh:'座位', ja:'シート', pt:'Assento'},
  'facing': {en:'Facing', ru:'Направление', zh:'朝向', ja:'向き', pt:'Direção'},
  'color': {en:'Color (Color Config ID)', ru:'Цвет (ID конфигурации)', zh:'颜色 (配色ID)', ja:'カラー (カラー設定ID)', pt:'Cor (ID de Configuração)'},
  'blue': {en:'Blue', ru:'Синий', zh:'蓝色', ja:'青', pt:'Azul'},
  'red': {en:'Red', ru:'Красный', zh:'红色', ja:'赤', pt:'Vermelho'},
  'green': {en:'Green', ru:'Зелёный', zh:'绿色', ja:'緑', pt:'Verde'},
  'yellow': {en:'Yellow', ru:'Жёлтый', zh:'黄色', ja:'黄', pt:'Amarelo'},
  'purple': {en:'Purple', ru:'Фиолетовый', zh:'紫色', ja:'紫', pt:'Roxo'},
  'pink': {en:'Pink', ru:'Розовый', zh:'粉色', ja:'ピンク', pt:'Rosa'},
  'black': {en:'Black', ru:'Чёрный', zh:'黑色', ja:'黒', pt:'Preto'},
  'white': {en:'White', ru:'Белый', zh:'白色', ja:'白', pt:'Branco'},
  'defaultDrivable': {en:'Default Drivable', ru:'Стандартный', zh:'默认可驾驶', ja:'デフォルト走行可能', pt:'Padrão Dirigível'},
  'milkcar': {en:'Milkcar', ru:'Молоковоз', zh:'奶车', ja:'ミルクカー', pt:'Carro Leite'},
  'textList': {en:'Text List', ru:'Текстовый список', zh:'文本列表', ja:'テキストリスト', pt:'Lista de Texto'},
  'apiDocs': {en:'API Docs', ru:'Документация', zh:'接口说明', ja:'API仕様', pt:'Docs da API'},
  'addVehicle': {en:'Add Vehicle', ru:'Добавить транспорт', zh:'添加载具', ja:'乗り物を追加', pt:'Adicionar Veículo'},
  'addAll': {en:'Add All', ru:'Добавить все', zh:'添加全部', ja:'すべて追加', pt:'Adicionar Todos'},
  'recordedVehicles': {en:'Recorded Vehicle IDs', ru:'Записанные ID транспорта', zh:'已收录载具ID', ja:'記録された乗り物ID', pt:'IDs de Veículos Registrados'},
  'specifyCoords': {en:'Specify Coordinates', ru:'Указать координаты', zh:'指定坐标', ja:'座標を指定', pt:'Especificar Coordenadas'},
  'coordHint': {en:'Leave empty to use last known player position.', ru:'Пусто = последняя позиция игрока', zh:'默认不填坐标时使用最近玩家位置', ja:'空欄の場合プレイヤーの最終位置を使用', pt:'Vazio usa a última posição do jogador'},
  'spawnAndDrive': {en:'Spawn & Drive', ru:'Спавн и вождение', zh:'生成并驾驶', ja:'スポーン＆運転', pt:'Gerar e Dirigir'},
  'spawnOnly': {en:'Spawn Only', ru:'Только спавн', zh:'只生成载具', ja:'スポーンのみ', pt:'Apenas Gerar'},
  'enterVehicle': {en:'Enter Nearest', ru:'Войти в ближайший', zh:'进入最近载具', ja:'最寄りに乗る', pt:'Entrar no Mais Próximo'},
  'exitVehicle': {en:'Exit Vehicle', ru:'Выйти', zh:'退出载具', ja:'乗り物から降りる', pt:'Sair do Veículo'},
  'destroy': {en:'Destroy', ru:'Уничтожить', zh:'销毁', ja:'破壊', pt:'Destruir'},
  'horn': {en:'Horn', ru:'Гудок', zh:'鸣笛', ja:'クラクション', pt:'Buzina'},
  'changeColor': {en:'Change Color', ru:'Сменить цвет', zh:'更换颜色', ja:'カラー変更', pt:'Mudar Cor'},
  'doors': {en:'Doors', ru:'Двери', zh:'车门', ja:'ドア', pt:'Portas'},
  'doorIndex': {en:'Door Index', ru:'Индекс двери', zh:'门索引', ja:'ドア番号', pt:'Índice da Porta'},
  'doorState': {en:'State (0=Close, 1=Open)', ru:'Состояние (0=Закрыть, 1=Открыть)', zh:'状态 (0=关, 1=开)', ja:'状態 (0=閉, 1=開)', pt:'Estado (0=Fechar, 1=Abrir)'},
  'toggleDoor': {en:'Toggle Door', ru:'Переключить дверь', zh:'切换门', ja:'ドア切替', pt:'Alternar Porta'},
  'enterHint': {en:"'Enter Nearest' uses the server's LastSpawnedVehicleId.", ru:'Использует LastSpawnedVehicleId', zh:'使用服务器记录的LastSpawnedVehicleId', ja:'サーバーのLastSpawnedVehicleIdを使用', pt:'Usa o LastSpawnedVehicleId do servidor'},
  'characterTitle': {en:'Ananta GM Character Switch', ru:'GM Смена персонажа', zh:'GM角色切换', ja:'GMキャラ切替', pt:'Troca de Personagem GM'},
  'characterSub': {en:'Local GM character switch tool, port {0}.', ru:'Локальный инструмент смены персонажа', zh:'本地GM角色切换操作台', ja:'ローカルGMキャラ切替ツール', pt:'Ferramenta local de troca de personagem'},
  'charSelect': {en:'Character Selection', ru:'Выбор персонажа', zh:'角色选择', ja:'キャラクター選択', pt:'Seleção de Personagem'},
  'searchOrEnterSpirit': {en:'Search or enter Spirit ID', ru:'Поиск или введите Spirit ID', zh:'搜索或输入 Spirit ID', ja:'検索またはSpirit ID入力', pt:'Pesquisar ou inserir Spirit ID'},
  'switchChar': {en:'Switch Character', ru:'Сменить персонажа', zh:'切换角色', ja:'キャラクター切替', pt:'Trocar Personagem'},
  'allSpiritIds': {en:'All Spirit IDs', ru:'Все Spirit ID', zh:'所有角色ID', ja:'全Spirit ID', pt:'Todos os Spirit IDs'},
  'clickCharHint': {en:'Click a character button or select from list, then switch.', ru:'Нажмите кнопку или выберите из списка', zh:'点击角色按钮或从列表中选择', ja:'キャラボタンをクリックまたはリストから選択', pt:'Clique num botão de personagem ou selecione da lista'},
  'weaponsTitle': {en:'Ananta GM Weapons Panel', ru:'GM Панель оружия', zh:'GM武器面板', ja:'GM武器パネル', pt:'Painel de Armas GM'},
  'weaponsSub': {en:'Weapon management panel, port {0}.', ru:'Панель управления оружием, порт {0}', zh:'武器管理面板，端口 {0}', ja:'武器管理パネル、ポート {0}', pt:'Painel de gerenciamento de armas, porta {0}'},
  'selectWeapon': {en:'Select Weapon', ru:'Выбор оружия', zh:'选择武器', ja:'武器を選択', pt:'Selecionar Arma'},
  'weaponIndex': {en:'Weapon Index (0-N)', ru:'Индекс оружия (0-N)', zh:'武器索引 (0-N)', ja:'武器インデックス (0-N)', pt:'Índice da Arma (0-N)'},
  'switchWeapon': {en:'Switch Weapon', ru:'Сменить оружие', zh:'切换武器', ja:'武器を切替', pt:'Trocar Arma'},
  'allWeapons': {en:'All Weapons', ru:'Всё оружие', zh:'所有武器', ja:'全武器', pt:'Todas as Armas'},
  'removeWeapon': {en:'Remove Weapon', ru:'Удалить оружие', zh:'移除武器', ja:'武器を削除', pt:'Remover Arma'},
  'removeIndex': {en:'Index to remove (0-N)', ru:'Индекс для удаления (0-N)', zh:'要移除的索引 (0-N)', ja:'削除するインデックス (0-N)', pt:'Índice a remover (0-N)'},
  'removeHint': {en:'Enter weapon index to remove from inventory.', ru:'Введите индекс оружия для удаления', zh:'输入武器索引从库存移除', ja:'インベントリから削除する武器インデックスを入力', pt:'Insira o índice da arma para remover do inventário'},
  'addAllWeapons': {en:'Add All Weapons', ru:'Добавить всё оружие', zh:'添加全部武器', ja:'全武器を追加', pt:'Adicionar Todas as Armas'},
  'clickWeaponHint': {en:'Click a weapon or select from list, then switch.', ru:'Нажмите или выберите из списка', zh:'点击武器或从列表选择', ja:'武器をクリックまたはリストから選択', pt:'Clique numa arma ou selecione da lista'},
  'enterWeaponIndex': {en:'Enter weapon index', ru:'Введите индекс оружия', zh:'请输入武器索引', ja:'武器インデックスを入力', pt:'Insira o índice da arma'},
  'weapon': {en:'Weapon', ru:'Оружие', zh:'武器', ja:'武器', pt:'Arma'},
  'npcTitle': {en:'Ananta GM NPC Panel', ru:'GM Панель NPC', zh:'GM NPC面板', ja:'GM NPCパネル', pt:'Painel NPC GM'},
  'npcSub': {en:'Port {0} - Use after entering game.', ru:'Порт {0} - Используйте после входа', zh:'端口 {0} - 进入游戏后使用', ja:'ポート {0} - ゲーム進入後に使用', pt:'Porta {0} - Use após entrar no jogo'},
  'npcSelect': {en:'NPC Selection', ru:'Выбор NPC', zh:'NPC选择', ja:'NPC選択', pt:'Seleção de NPC'},
  'searchOrEnterNpc': {en:'Search or enter NPC Formwork ID', ru:'Поиск или введите NPC ID', zh:'搜索或输入NPC ID', ja:'検索またはNPC ID入力', pt:'Pesquisar ou inserir NPC ID'},
  'spawnNpc': {en:'Spawn NPC', ru:'Спавн NPC', zh:'生成NPC', ja:'NPCスポーン', pt:'Gerar NPC'},
  'spawnAll': {en:'Spawn All', ru:'Спавн всех', zh:'生成全部', ja:'すべてスポーン', pt:'Gerar Todos'},
  'destroyAllNpcs': {en:'Destroy All NPCs', ru:'Уничтожить всех NPC', zh:'销毁所有NPC', ja:'全NPCを破壊', pt:'Destruir Todos NPCs'},
  'npcFormworkIds': {en:'NPC Formwork IDs', ru:'NPC ID', zh:'NPC模板ID', ja:'NPCフォームワークID', pt:'IDs de NPC'},
  'coordDefaultHint': {en:'Leave coordinates empty to use default position (1003, 0, 2000).', ru:'Пустые координаты = позиция по умолчанию', zh:'不填坐标使用默认位置', ja:'座標を空にするとデフォルト位置を使用', pt:'Deixe coordenadas vazias para posição padrão'},
  'enterNpcId': {en:'Enter NPC ID', ru:'Введите NPC ID', zh:'请输入NPC ID', ja:'NPC IDを入力', pt:'Insira o ID do NPC'}
};
function lang() { return getCookie('gmLang') || 'en'; }
function t(key) {
  if (!T[key]) return key;
  return T[key][lang()] || T[key]['en'] || key;
}
function setLang(l) {
  setCookie('gmLang', l, 365);
  applyLang();
}
function applyLang() {
  var els = document.querySelectorAll('[data-t]');
  for (var i = 0; i < els.length; i++) {
    els[i].textContent = t(els[i].getAttribute('data-t'));
  }
  var phs = document.querySelectorAll('[data-tp]');
  for (var i = 0; i < phs.length; i++) {
    phs[i].setAttribute('placeholder', t(phs[i].getAttribute('data-tp')));
  }
  var sel = document.getElementById('langSel');
  if (sel) sel.value = lang();
}
document.addEventListener('DOMContentLoaded', applyLang);
</script>
""";
    }

    /// <summary>
    /// Returns an HTML snippet with a fixed-position language selector dropdown
    /// supporting en, ru, zh, ja, and pt.
    /// </summary>
    public static string GetLangSelector()
    {
        return """
<div style="position:fixed;top:10px;right:10px;z-index:9999;">
  <select id="langSel" onchange="setLang(this.value)" style="padding:6px 10px;background:#1e293b;color:#e5e7eb;border:1px solid rgba(255,255,255,.2);border-radius:6px;font-size:13px;cursor:pointer;">
    <option value="en">English</option>
    <option value="ru">Русский</option>
    <option value="zh">中文</option>
    <option value="ja">日本語</option>
    <option value="pt">Português</option>
  </select>
</div>
""";
    }
}
