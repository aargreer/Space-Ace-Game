package ;
import flash.display.BitmapData;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.system.FlxSplash;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;

class LevelWin extends FlxSplash{
    private var splash = new FlxSprite();
    public function new(background:BitmapData) {
        this.splash.loadGraphic(background, false, 640, 480, false);
    }
}
