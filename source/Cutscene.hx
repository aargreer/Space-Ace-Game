package ;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.system.FlxSplash;
import flixel.FlxState;
import flixel.FlxG;

//simple FlxState class that transitions between levels
class Cutscene extends FlxSplash{
    //uses a timer variable, incremented every frame; used in fade effects
    private var timer = 0;
    private var txt:FlxText;

    override public function create():Void {
        this.bgColor = FlxColor.BLACK;

        txt = new FlxText(0, 0, 0, "LEVEL " + Main.levelNum, 36);

        txt.screenCenter();
        txt.alpha = 0;
        add(txt);
    }

    override public function update(elapsed:Float){
        //float for the fading of the text (1 second fade in/out, so gradient is some fraction over 60)
        var gradient = ((timer % 60) / 60);

        //if in the first second, applies a fade in effect based on gradient
        if(timer < 60){
            txt.alpha = gradient;
        }

        //performs 1 second fade out after 4 seconds
        if(timer > 240){
            if(txt.alpha != 0){
                txt.alpha = 1 - gradient;
            }
        }

        //at 5 seconds, changes to next level
        if(timer >= 299){
            FlxG.switchState(new Level());
        }

        timer++;
    }
}
