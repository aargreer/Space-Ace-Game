package ;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;

//player class that contains the ship sprite and logic for health/shields
//(plus method for when player receives damage)
class Player extends FlxSprite{
    private var spr:FlxSprite;
    private var shields:Float;
    public var healthAmount:FlxText;
    public var shieldAmount:FlxText;

    public function new() {
        super();

        this.spr = new FlxSprite();
        this.spr.loadGraphic("assets/images/playerShip.png", false, 640, 480, false);
        this.spr.setGraphicSize(672, 0);

        this.shields = 100;
        this.health = 100;

        //HUD elements for showing shields and health
        healthAmount = new FlxText(0, 458, 0, "" + this.health, 12, true);
        shieldAmount = new FlxText(0, 443, 0, "" + this.shields, 12, true);

        healthAmount.setFormat(12, FlxColor.RED, FlxColor.TRANSPARENT, true);
        shieldAmount.setFormat(12, FlxColor.BLUE, FlxColor.TRANSPARENT, true);
    }

    //field access methods
    public function getHP():Float{ return this.health; }
    public function getShields():Float{ return this.shields; }
    public function setHP(hp:Int){ this.health = hp; }

    //hits the player, depleting their shields; if shields are down, player takes health damage
    //(shields regenerate, health does NOT)
    public function hit(strength:Float){
        if(strength >= this.shields){
            this.hurt(strength - this.shields);
            this.shields = 0;
        } else this.shields -= strength;

        //game over condition
        if(this.health <= 0){
            this.kill();
            FlxG.switchState(new GameOver());
        }

        /*
        FlxG.camera.flash(FlxColor.RED, 0.25, false);
        FlxG.camera.shake(0.25, 0.25, false);
         */
    }

    //heals player (used for power-ups, not yet implemented)
    public function heal(amount:Float){
        if(this.health + amount > 100){
            this.health = 100;
        } else this.health += amount;
    }

    //regens shields based on a given amount
    public function shieldRegen(amount:Float){
        if(this.shields + amount > 100){
            this.shields = 100;
        } else this.shields += amount;
    }

    public function getGraphic():FlxSprite{ return this.spr; }
}
