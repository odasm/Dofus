﻿package com.ankamagames.dofus.network.messages.game.guild.tax
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import com.ankamagames.dofus.network.types.game.guild.tax.TaxCollectorBasicInformations;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class TaxCollectorMovementMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5633;

        private var _isInitialized:Boolean = false;
        public var hireOrFire:Boolean = false;
        public var basicInfos:TaxCollectorBasicInformations;
        public var playerId:uint = 0;
        public var playerName:String = "";

        public function TaxCollectorMovementMessage()
        {
            this.basicInfos = new TaxCollectorBasicInformations();
            super();
        }

        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (5633);
        }

        public function initTaxCollectorMovementMessage(hireOrFire:Boolean=false, basicInfos:TaxCollectorBasicInformations=null, playerId:uint=0, playerName:String=""):TaxCollectorMovementMessage
        {
            this.hireOrFire = hireOrFire;
            this.basicInfos = basicInfos;
            this.playerId = playerId;
            this.playerName = playerName;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.hireOrFire = false;
            this.basicInfos = new TaxCollectorBasicInformations();
            this.playerName = "";
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
            this.serializeAs_TaxCollectorMovementMessage(output);
        }

        public function serializeAs_TaxCollectorMovementMessage(output:ICustomDataOutput):void
        {
            output.writeBoolean(this.hireOrFire);
            this.basicInfos.serializeAs_TaxCollectorBasicInformations(output);
            if (this.playerId < 0)
            {
                throw (new Error((("Forbidden value (" + this.playerId) + ") on element playerId.")));
            };
            output.writeVarInt(this.playerId);
            output.writeUTF(this.playerName);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_TaxCollectorMovementMessage(input);
        }

        public function deserializeAs_TaxCollectorMovementMessage(input:ICustomDataInput):void
        {
            this.hireOrFire = input.readBoolean();
            this.basicInfos = new TaxCollectorBasicInformations();
            this.basicInfos.deserialize(input);
            this.playerId = input.readVarUhInt();
            if (this.playerId < 0)
            {
                throw (new Error((("Forbidden value (" + this.playerId) + ") on element of TaxCollectorMovementMessage.playerId.")));
            };
            this.playerName = input.readUTF();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.guild.tax

