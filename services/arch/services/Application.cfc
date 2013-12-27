component  {

	this.name = "DemoRestServices";
	this.webAdminPassword = 'txqn59';
	this.environment = 'dev'; // dev | test | prod

	public boolean function onApplicationStart() {

        reloadApp();
		reloadRest();

		return true;
	}

	public boolean function onRequestStart() {

		if (isDefined("URL.reRest") and URL.reRest) {
			reloadRest();
		}
		if (isDefined("URL.reSet") and URL.reSet) {
			reloadApp();
		}

        application.Security = createObject('component', 'services.arch.Security');
		return true;
	}
	private void function reloadApp() {
        application.datasource = "demo";
        application.Crypto = createObject('component', 'services.arch.Crypto');
        application.Security = createObject('component', 'services.arch.Security');
        application.AuditLogger = createObject('component', 'services.arch.Audit')
	}
	private void function reloadRest() {
		restinitapplication('/var/www/api','demo');
	}
}
