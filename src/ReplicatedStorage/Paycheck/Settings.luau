local module = {
	General_Config = { 
		Leaderstats_Name = "leaderstats";
		Leaderstat_SueldoName = "Sueldo"; 
	};

	Paycheck_Config = {
		Bank_Name = "MEXIBANK"; 
		Notification_Type = 2; 
		Cooldown = 7; 

		Regular_Paycheck = 4500; 
		Increased_Paycheck = 1000; 

		Regular_Reason = "Trabajando"; 
		Increased_Reason = "Trabajando"; 

		Gamepass_Enabled = false; 
		Gamepass_Id = 116703167;
		Gamepass_Multiplier = 2;

		Regular_Teams = {
			["CAJERO"] = true;
			["EMPAQUETADOR"] = true;
		};

		Increased_Teams = {};
	};
}


return module
