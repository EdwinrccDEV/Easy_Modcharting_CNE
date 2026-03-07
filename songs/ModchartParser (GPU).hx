/*
Modchart Parser (GPU) by Edwin
*/

import funkin.game.PlayState;

function postCreate() {
    importScript("data/scripts/modchartManager.hx");
    var songName = PlayState.SONG.meta.name.toLowerCase();
    var data = CoolUtil.parseJson('assets/songs/' + songName + '/modchart (GPU).json');
    setupFromJson(data);
}