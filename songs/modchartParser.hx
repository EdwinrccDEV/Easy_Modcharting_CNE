import funkin.game.PlayState;

var mngr;

function postCreate() {
    var cpuData = loadModchartJson("CPU");
    var gpuData = loadModchartJson("GPU");
    if (cpuData == null && gpuData == null) return;

    if (cpuData != null) setupCpuModchart(cpuData);

    if (gpuData != null) {
        importScript("data/scripts/modchartManager.hx");
        setupFromJson(gpuData);
    }
}


function findModchartFile(kind:String):String {
    var songNames:Array<String> = [];

    try {
        if (PlayState.instance != null && PlayState.instance.curSongID != null) {
            var id = StringTools.trim(Std.string(PlayState.instance.curSongID));
            if (id != "" && songNames.indexOf(id) == -1) songNames.push(id);
        }
    } catch (e:Dynamic) {}

    try {
        if (PlayState.SONG != null && PlayState.SONG.meta != null && PlayState.SONG.meta.name != null) {
            var raw = Std.string(PlayState.SONG.meta.name);
            if (raw != "" && songNames.indexOf(raw) == -1) songNames.push(raw);
            var low = raw.toLowerCase();
            if (low != "" && songNames.indexOf(low) == -1) songNames.push(low);
        }
    } catch (e:Dynamic) {}

    if (songNames.length == 0) return null;

    var diff:String = null;
    var variation:String = null;
    try { diff = PlayState.difficulty; } catch (e:Dynamic) {}
    try { variation = PlayState.variation; } catch (e:Dynamic) {}
    if (diff != null && StringTools.trim(Std.string(diff)) == "") diff = null;
    if (variation != null) {
        var v = StringTools.trim(Std.string(variation));
        if (v == "" || v == "default") variation = null;
    }

    var fileNames:Array<String> = [];
    if (diff != null && variation != null)
        fileNames.push('modchart (' + kind + ')-' + diff + '-' + variation + '.json');
    if (variation != null)
        fileNames.push('modchart (' + kind + ')-any-' + variation + '.json');
    if (diff != null)
        fileNames.push('modchart (' + kind + ')-' + diff + '.json');
    fileNames.push('modchart (' + kind + ').json');

    for (song in songNames) {
        for (file in fileNames) {
            var resolved:String = null;
            try {
                resolved = Paths.getPath('songs/' + song + '/' + file);
            } catch (e:Dynamic) {
                resolved = null;
            }
            if (resolved != null && Assets.exists(resolved)) return resolved;
        }
    }
    return null;
}

function loadModchartJson(kind:String):Dynamic {
    var path = findModchartFile(kind);
    if (path == null) return null; 

    var content:String = null;
    try {
        content = Assets.getText(path);
    } catch (e:Dynamic) {
        trace('[EasyModchart] Could not read "' + path + '": ' + e);
        return null;
    }
    if (content == null || StringTools.trim(content) == "") {
        trace('[EasyModchart] File "' + path + '" is empty, skipping.');
        return null;
    }

    var data:Dynamic = null;
    try {
        data = CoolUtil.parseJson(path);
    } catch (e:Dynamic) {
        trace('[EasyModchart] Invalid JSON in "' + path + '": ' + e);
        return null;
    }
    if (data == null) {
        trace('[EasyModchart] JSON is null in "' + path + '", skipping.');
        return null;
    }
    if (data.modchart == null) {
        trace('[EasyModchart] "' + path + '" has no "modchart" field, skipping.');
        return null;
    }
    trace('[EasyModchart] ' + kind + ' modchart loaded: ' + path);
    return data;
}

// Collects loader names from {"loader": "centerRotate"} or {"loader": ["a", "b"]}.
function getLoaderNames(raw:Dynamic):Array<String> {
    var names:Array<String> = [];
    if (raw == null) return names;
    // Duck-typed array check (arrays expose length but no charAt) to stay hscript-safe.
    if (raw.length != null && raw.charAt == null) {
        for (n in cast(raw, Array<Dynamic>)) {
            var s = Std.string(n);
            if (s != null && s != "" && s != "null" && names.indexOf(s) == -1) names.push(s);
        }
    } else {
        var s = Std.string(raw);
        if (s != null && s != "" && s != "null") names.push(s);
    }
    return names;
}

// True when "name" is (or extends) an already-loaded parent modifier,
// e.g. "centerRotateX" with parent "centerRotate" loaded.
function isSubOfLoadedParent(name:Dynamic, parents:Array<String>):Bool {
    var low = Std.string(name).toLowerCase();
    for (p in parents) {
        if (low == p || StringTools.startsWith(low, p)) return true;
    }
    return false;
}

function setupCpuModchart(data:Dynamic) {
    try {
        add(mngr = new modchart.Manager());
    } catch (e:Dynamic) {
        trace('[EasyModchart] CPU modchart found, but the funkin-modchart library is not installed. Skipping CPU side.');
        return;
    }

    var addMod = mngr.addModifier;
    var setValue = mngr.setPercent;
    var easeFunc = mngr.ease;
    var onBeat = mngr.callback;

    var events:Array<Dynamic> = null;
    try {
        events = cast(data.modchart, Array<Dynamic>);
    } catch (e:Dynamic) {
        trace('[EasyModchart] The "modchart" field is not an array, skipping.');
        return;
    }
    if (events == null) return;

    // Preload pass: "loader" entries register parent modifiers (e.g. "centerRotate")
    // so that sub-modifier keys (e.g. "centerRotateX") have an instance reading them.
    // A modifier event alone only sets a percent key; without its parent loaded it
    // would silently do nothing (plus a "not found" warning from the library).
    var loadedParents:Array<String> = [];
    for (event in events) {
        if (event == null || event.loader == null) continue;
        for (parent in getLoaderNames(event.loader)) {
            addMod(parent);
            var low = parent.toLowerCase();
            if (loadedParents.indexOf(low) == -1) loadedParents.push(low);
        }
    }

    for (event in events) {
        if (event == null) continue;
        if (event.loader != null) continue; // already handled in the preload pass above
        if (event.modifier == null) {
            trace('[EasyModchart] Event without "modifier", skipped.');
            continue;
        }

        // Sub-modifier keys (e.g. "centerRotateX") are percent keys read by an
        // already-loaded parent: there is no class to register, so skip addModifier
        // and avoid the library's "not found" warning.
        if (!isSubOfLoadedParent(event.modifier, loadedParents)) addMod(event.modifier);

        var evtStartBeat = event.startStep != null ? event.startStep / 4 : event.startBeat;
        var evtEndBeat = event.endStep != null ? event.endStep / 4 : event.endBeat;
        if (evtStartBeat == null) {
            trace('[EasyModchart] Event "' + event.modifier + '" without startBeat/startStep, skipped.');
            continue;
        }
        var ease = CoolUtil.flxeaseFromString(event.ease, event.easeDir);

        if (event.endValue != null) {
            var mod = event.modifier;
            var val = event.value;
            var endVal = event.endValue;
            onBeat(evtStartBeat, function() { setValue(mod, val); });
            if (evtEndBeat != null) {
                var duration = evtEndBeat - evtStartBeat;
                easeFunc(mod, evtStartBeat, duration, endVal, ease);
            }
        } else if (evtEndBeat != null) {
            var duration = evtEndBeat - evtStartBeat;
            easeFunc(event.modifier, evtStartBeat, duration, event.value, ease);
        } else {
            var mod = event.modifier;
            var val = event.value;
            onBeat(evtStartBeat, function() { setValue(mod, val); });
        }
    }
}
