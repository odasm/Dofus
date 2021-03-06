﻿package com.ankamagames.dofus.network.messages.game.context.fight
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import __AS3__.vec.Vector;
    import com.ankamagames.dofus.network.types.game.action.fight.FightDispellableEffectExtendedInformations;
    import com.ankamagames.dofus.network.types.game.actions.fight.GameActionMark;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;
    import __AS3__.vec.*;

    [Trusted]
    public class GameFightSpectateMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6069;

        private var _isInitialized:Boolean = false;
        public var effects:Vector.<FightDispellableEffectExtendedInformations>;
        public var marks:Vector.<GameActionMark>;
        public var gameTurn:uint = 0;
        public var fightStart:uint = 0;

        public function GameFightSpectateMessage()
        {
            this.effects = new Vector.<FightDispellableEffectExtendedInformations>();
            this.marks = new Vector.<GameActionMark>();
            super();
        }

        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6069);
        }

        public function initGameFightSpectateMessage(effects:Vector.<FightDispellableEffectExtendedInformations>=null, marks:Vector.<GameActionMark>=null, gameTurn:uint=0, fightStart:uint=0):GameFightSpectateMessage
        {
            this.effects = effects;
            this.marks = marks;
            this.gameTurn = gameTurn;
            this.fightStart = fightStart;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.effects = new Vector.<FightDispellableEffectExtendedInformations>();
            this.marks = new Vector.<GameActionMark>();
            this.gameTurn = 0;
            this.fightStart = 0;
            this._isInitialized = false;
        }

        override public function pack(output:ICustomDataOutput):void
        {
            var data:ByteArray = new ByteArray();
            this.serialize(new CustomDataWrapper(data));
            writePacket(output, this.getMessageId(), data);
        }

        override public function unpack(input:ICustomDataInput, length:uint):void
        {
            this.deserialize(input);
        }

        public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_GameFightSpectateMessage(output);
        }

        public function serializeAs_GameFightSpectateMessage(output:ICustomDataOutput):void
        {
            output.writeShort(this.effects.length);
            var _i1:uint;
            while (_i1 < this.effects.length)
            {
                (this.effects[_i1] as FightDispellableEffectExtendedInformations).serializeAs_FightDispellableEffectExtendedInformations(output);
                _i1++;
            };
            output.writeShort(this.marks.length);
            var _i2:uint;
            while (_i2 < this.marks.length)
            {
                (this.marks[_i2] as GameActionMark).serializeAs_GameActionMark(output);
                _i2++;
            };
            if (this.gameTurn < 0)
            {
                throw (new Error((("Forbidden value (" + this.gameTurn) + ") on element gameTurn.")));
            };
            output.writeVarShort(this.gameTurn);
            if (this.fightStart < 0)
            {
                throw (new Error((("Forbidden value (" + this.fightStart) + ") on element fightStart.")));
            };
            output.writeInt(this.fightStart);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GameFightSpectateMessage(input);
        }

        public function deserializeAs_GameFightSpectateMessage(input:ICustomDataInput):void
        {
            var _item1:FightDispellableEffectExtendedInformations;
            var _item2:GameActionMark;
            var _effectsLen:uint = input.readUnsignedShort();
            var _i1:uint;
            while (_i1 < _effectsLen)
            {
                _item1 = new FightDispellableEffectExtendedInformations();
                _item1.deserialize(input);
                this.effects.push(_item1);
                _i1++;
            };
            var _marksLen:uint = input.readUnsignedShort();
            var _i2:uint;
            while (_i2 < _marksLen)
            {
                _item2 = new GameActionMark();
                _item2.deserialize(input);
                this.marks.push(_item2);
                _i2++;
            };
            this.gameTurn = input.readVarUhShort();
            if (this.gameTurn < 0)
            {
                throw (new Error((("Forbidden value (" + this.gameTurn) + ") on element of GameFightSpectateMessage.gameTurn.")));
            };
            this.fightStart = input.readInt();
            if (this.fightStart < 0)
            {
                throw (new Error((("Forbidden value (" + this.fightStart) + ") on element of GameFightSpectateMessage.fightStart.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.context.fight

