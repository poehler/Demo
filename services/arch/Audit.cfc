component {
    public any function logAction(numeric user_id=0,
                                  required string type,
                                  required string message,
                                  numeric location_id=0,
                                  numeric gateway_id=0,
                                  numeric device_id=0,
                                  numeric channel_id=0) {
        try {
	        include "audits/sql_i_audit_trails_01.cfm";
            return true;
        } catch (any e) {
            return false;
        }
    }
}