[
  {
    "secrets": [{
    	"name": "VTT_DBPASSWORD",
    	"valuefrom": "${database-password-arn}"
    }],
    "name": "webapp",
    "image": "${container}",
    "command": ${command},
    "portMappings": [
    	{
    		"containerPort": 3000
    	}
    ],
    "environment": [
    	{
    		"name": "VTT_LISTENHOST",
    		"value": "0.0.0.0"
    	},
    	{
    		"name": "VTT_DBUSER",
    		"value": "${database-username}"
    	},
    	{
    		"name": "VTT_DBNAME",
    		"value": "${database-name}"
    	},
    	{
    		"name": "VTT_DBPORT",
    		"value": "${database-port}"
    	},
    	{
    		"name": "VTT_DBHOST",
    		"value": "${database-host}"
    	}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "ap-southeast-2",
        "awslogs-group": "${log-group}",
        "awslogs-stream-prefix": "webapp"
      }
    }
  }
]