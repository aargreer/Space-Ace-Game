package ;
import flixel.text.FlxText;

//simple score class represented as an FlxText
class Score extends FlxText {
    private var score:Int;
    private var txt:FlxText;

    override public function new(value:Int){
        super(5, 5, 0, "", 16);
        this.txt = new FlxText(5, 5, 0, "", 16);
        this.score = value;
        this.set(value);
    }

    //sets the score and pads leading zeroes using a log base 10 function
    public function set(updated:Int){
        if(updated <= 999999){
            this.score = updated;
        } else this.score = 999999;

        if(updated == 0){
            this.text = "000000";
        } else { this.text = StringTools.lpad("", "0", 5 - Math.floor(logBaseTen(updated))) + updated; }

        Main.globalScore = this.score;
    }

    //field access methods
    public function getScore():Int{ return this.score; }
    public function getGraphic():FlxText{ return this.txt; }

    public function add(amount:Int){
        this.score += amount;
        set(this.score);
    }

    //Math.log() in haxe is always base two, so this simple function returns log base 10 of a given float
    private function logBaseTen(v:Float):Float{ return (Math.log(v) / Math.log(10)); }
}
