﻿package com.ankamagames.dofus.logic.game.common.actions.party
{
    import com.ankamagames.jerakine.handlers.messages.Action;

    public class PartyKickRequestAction implements Action 
    {

        public var playerId:uint;
        public var partyId:int;


        public static function create(partyId:int, playerId:uint):PartyKickRequestAction
        {
            var a:PartyKickRequestAction = new (PartyKickRequestAction)();
            a.partyId = partyId;
            a.playerId = playerId;
            return (a);
        }


    }
}//package com.ankamagames.dofus.logic.game.common.actions.party

