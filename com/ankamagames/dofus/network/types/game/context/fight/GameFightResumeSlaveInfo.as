﻿package com.ankamagames.dofus.network.types.game.context.fight
{
    import com.ankamagames.jerakine.network.INetworkType;
    import __AS3__.vec.Vector;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;
    import __AS3__.vec.*;

    [Trusted]
    public class GameFightResumeSlaveInfo implements INetworkType 
    {

        public static const protocolId:uint = 364;

        public var slaveId:int = 0;
        public var spellCooldowns:Vector.<GameFightSpellCooldown>;
        public var summonCount:uint = 0;
        public var bombCount:uint = 0;

        public function GameFightResumeSlaveInfo()
        {
            this.spellCooldowns = new Vector.<GameFightSpellCooldown>();
            super();
        }

        public function getTypeId():uint
        {
            return (364);
        }

        public function initGameFightResumeSlaveInfo(slaveId:int=0, spellCooldowns:Vector.<GameFightSpellCooldown>=null, summonCount:uint=0, bombCount:uint=0):GameFightResumeSlaveInfo
        {
            this.slaveId = slaveId;
            this.spellCooldowns = spellCooldowns;
            this.summonCount = summonCount;
            this.bombCount = bombCount;
            return (this);
        }

        public function reset():void
        {
            this.slaveId = 0;
            this.spellCooldowns = new Vector.<GameFightSpellCooldown>();
            this.summonCount = 0;
            this.bombCount = 0;
        }

        public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_GameFightResumeSlaveInfo(output);
        }

        public function serializeAs_GameFightResumeSlaveInfo(output:ICustomDataOutput):void
        {
            output.writeInt(this.slaveId);
            output.writeShort(this.spellCooldowns.length);
            var _i2:uint;
            while (_i2 < this.spellCooldowns.length)
            {
                (this.spellCooldowns[_i2] as GameFightSpellCooldown).serializeAs_GameFightSpellCooldown(output);
                _i2++;
            };
            if (this.summonCount < 0)
            {
                throw (new Error((("Forbidden value (" + this.summonCount) + ") on element summonCount.")));
            };
            output.writeByte(this.summonCount);
            if (this.bombCount < 0)
            {
                throw (new Error((("Forbidden value (" + this.bombCount) + ") on element bombCount.")));
            };
            output.writeByte(this.bombCount);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GameFightResumeSlaveInfo(input);
        }

        public function deserializeAs_GameFightResumeSlaveInfo(input:ICustomDataInput):void
        {
            var _item2:GameFightSpellCooldown;
            this.slaveId = input.readInt();
            var _spellCooldownsLen:uint = input.readUnsignedShort();
            var _i2:uint;
            while (_i2 < _spellCooldownsLen)
            {
                _item2 = new GameFightSpellCooldown();
                _item2.deserialize(input);
                this.spellCooldowns.push(_item2);
                _i2++;
            };
            this.summonCount = input.readByte();
            if (this.summonCount < 0)
            {
                throw (new Error((("Forbidden value (" + this.summonCount) + ") on element of GameFightResumeSlaveInfo.summonCount.")));
            };
            this.bombCount = input.readByte();
            if (this.bombCount < 0)
            {
                throw (new Error((("Forbidden value (" + this.bombCount) + ") on element of GameFightResumeSlaveInfo.bombCount.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.types.game.context.fight

