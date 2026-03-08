/*
Modchart Parser (CPU) by Edwin
*/

import modchart.Manager;
import funkin.game.PlayState;

var mngr;

function postCreate() {
    add(mngr = new Manager());

    addMod   = mngr.addModifier;
    setValue = mngr.setPercent;
    ease     = mngr.ease;
    callback = mngr.callback;

    setupModchart();
}

function setupModchart() {
    var songName = PlayState.SONG.meta.name.toLowerCase();
    var data = CoolUtil.parseJson('assets/songs/' + songName + '/modchart (CPU).json');

    if (data == null)
        return;

    for (event in cast(data.modchart, Array<Dynamic>)) {

        // handle normal events
        addMod(event.modifier);

        var evtStartBeat = event.startStep != null ? event.startStep / 4 : event.startBeat;
        var evtEndBeat = event.endStep != null ? event.endStep / 4 : event.endBeat;
        var easeFunc = CoolUtil.flxeaseFromString(event.ease, event.easeDir);

        if (event.endValue != null) {
            var mod = event.modifier;
            var val = event.value;
            var endVal = event.endValue;
            callback(evtStartBeat, function() { setValue(mod, val); });
            if (evtEndBeat != null) {
                var duration = evtEndBeat - evtStartBeat;
                ease(mod, evtStartBeat, duration, endVal, easeFunc);
            }
        } else if (evtEndBeat != null) {
            var duration = evtEndBeat - evtStartBeat;
            ease(event.modifier, evtStartBeat, duration, event.value, easeFunc);
        } else {
            var mod = event.modifier;
            var val = event.value;
            callback(evtStartBeat, function() { setValue(mod, val); });
        }
    }
}
