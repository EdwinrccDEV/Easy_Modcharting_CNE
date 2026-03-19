/*
Modchart Parser (GPU) by Edwin
*/

import funkin.game.PlayState;

function postCreate() {
    importScript("data/scripts/modchartManager.hx");
    var songName = PlayState.SONG.meta.name.toLowerCase();
    var path = 'assets/songs/' + songName + '/modchart (GPU).json';
    if (!Assets.exists(path)) return;
    var content = Assets.getText(path);
    if (content == null || StringTools.trim(content) == '') return;
    var data = CoolUtil.parseJson(path);
    setupFromJson(data);
}
