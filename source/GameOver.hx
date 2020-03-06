package ;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.system.FlxSplash;
import flixel.FlxState;
import flixel.FlxG;

//simple FlxState for the game over condition; displays GAME OVER and final score
class GameOver extends FlxSplash{
    //timer used for fade in/out effects; incremented every frame
    private var timer = 0;
    private var txt:FlxText;
    private var score:Score;

    override public function create():Void {
        this.bgColor = FlxColor.BLACK;

        //displays message depending on whether the player has beat the final level
        if(Main.gameWin){
            txt = new FlxText(0, 0, 0, "GAME WIN", 36);
        } else txt = new FlxText(0, 0, 0, "GAME OVER", 36);

        score = new Score(Main.globalScore);

        txt.screenCenter();
        score.screenCenter();

        score.alpha = 0;
        txt.alpha = 0;

        add(txt);
        add(score);

        score.y += 50;
    }

    override public function update(elapsed:Float){
        //gradient for editing alpha for fade effects; float, represented as a fraction over 60 (frames per second)
        var gradient = ((timer % 60) / 60);

        //fade in for the first second
        if(timer < 60){
            txt.alpha = gradient;
            score.alpha = gradient;
        }

        //fade out after 4 seconds
        if(timer > 240){
            if(txt.alpha != 0){
                txt.alpha = 1 - gradient;
            }
            if(score.alpha != 0){
                score.alpha = 1 - gradient;
            }
        }

        //sends player back to main menu
        if(timer >= 299){
            Main.globalScore = 0;
            Main.gameWin = false;
            FlxG.switchState(new PlayState());
        }

        timer++;
    }
}
