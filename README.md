# DISCLAIMER !!!!!!!!!!!!
NONE OF THIS IS FINAL !!!!!!!!!!! im still trying to move stuff over from camellia,  
so some shit is hardcoded for now (like receptor animations)  
until i can figure out a good way to separate it it's gonna be a little messy

# <div align="center">Nevermore</div>
<div align="center">

A rhythm game engine/framework written in HaxeFlixel, designed for scalability and performance.

This was written with Never2x (a Friday Night Funkin' fork/rewrite) in mind, but this can be used  
outside of Friday Night Funkin' as well.

</div>

# <div align="center"> Features</div>
## Gameplay, out of the box
The project offers a simple way to set up gameplay without being too overbearing.
```hx
import nevermore.skins.Noteskin;
import nevermore.play.*;
import nevermore.core.Conductor;
import nevermore.core.Song;

Nevermore.init();

var skin = Noteskin.get('funkin');
var songID:String = 'Cyber Inductance';
var difficulty:String = 'Hard';

// make a strumline
var strumline = new Strumline(0, 50, skin);
strumline.screenCenter(X);

// make a playfield
var playfield = new PlayField([strumline], 0);
add(playfield);

// load the audio and chart
Conductor.inst = FlxG.sound.load(Assets.audio('$songID/Inst'));
playfield.load(Song.load(songID, difficulty), {
	randomizedNotes: true,
	sustains: false
});

// start
Conductor.play();
```

## Modcharting
The project supports modcharting, the likes of something you'd see on NotITG.  
Albeit, it might be a little lackluster in terms of how much it's capable of.

(see ModchartManager.hx for more)
```hx
import nevermore.modchart.ModchartManager;

var playfield = new PlayField([], 0);
add(playfield);

var modchart = new ModchartManager();
modchart.setAt(2, 'drunk', 0.75);
modchart.setAt(3, 'tipsy', 2);
// also supports ProxyFields if that's your kinda thing

playfield.modchart = modchart;
```

# Get Started
To start using this project, simply `haxelib git nevermore <this repo link>` and add it to your Project.xml.

If you want, you can also use it as a submodule via a `.haxelib` folder in your project's root folder.

Then, simply call `Nevermore.init();` any time after making a FlxGame instance.

```hx
import nevermore.Nevermore;

class Main extends openfl.display.Sprite {
	public function new() {
		super();

		addChild(new flixel.FlxGame(0, 0, InitState));
		Nevermore.init();
	}
}

// calling it here works as well
class InitState extends flixel.FlxState {
	override function create():Void {
		Nevermore.init();
	}
}
```

# Credits
* RapperGF - Architecture and API suggestions
* Marsh - Bugfixes and scroll velocity support
* SrtPro278 - Modchart, sustain, and quantization functionality/rendering
* Vs. Camellia - Never2x

# <div align="center">Artificial Intelligence (such as ChatGPT, Gemini, Github Copilot, DeepSeek) has not been used and/or assisted in the making of this project.</div>