package ;
import flixel.FlxSprite;
import flixel.text.FlxText;

class MenuButton extends FlxSprite{
    private var txt:FlxText;
    private var onClick:Void->Void;

    public function new(x:Float, y:Float, text:String, ?callBack:Void->Void) {
        super();
        this.loadGraphic("assets/images/menuButton.png", false, 156, 56, false);

        this.x = x;
        this.y = y;

        this.txt = new FlxText(this.x + 6, this.y + 14, 0, text, 18, true);
        if(callBack != null){
            this.onClick = callBack;
        }
    }

    public function getText():FlxText{
        return this.txt;
    }
}
