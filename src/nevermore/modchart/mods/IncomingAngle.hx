package nevermore.modchart.mods;

import nevermore.play.Receptor;

class IncomingAngle extends BaseModifier {
    var incomingAngleX:ModifierValue;
    var incomingAngleY:ModifierValue;
    @:alias(incomingangle) var incomingAngleZ:ModifierValue;
    var incomingAngleXLANE:ModifierValue;
    var incomingAngleYLANE:ModifierValue;
    @:alias(incomingangleLANE) var incomingAngleZLANE:ModifierValue;

    public function new(parent:ModchartManager) {
        super(parent);
        priority = 900;
    }

    override function modifiesPosition(_):Bool {return true;}
    override function adjustPos(_, pos:Vector3, _, _, _, lane:Int, _, field:Strumline, type:ObjectType) {
        if (type == RECEPTOR) return;

		var receptor:Receptor = field.members[lane];
        pos.x -= receptor.modchartPos.x;
        pos.y -= receptor.modchartPos.y;
        pos.z -= receptor.modchartPos.z;

        pos.rotate(incomingAngleX + incomingAngleXLANE, incomingAngleY + incomingAngleYLANE, incomingAngleZ + incomingAngleZLANE);

        pos.x += receptor.modchartPos.x;
        pos.y += receptor.modchartPos.y;
        pos.z += receptor.modchartPos.z;
    }
}