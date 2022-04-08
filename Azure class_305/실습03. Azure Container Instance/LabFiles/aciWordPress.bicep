@secure()
param mySqlPassword string
param containerGroupName string = 'aci-wordpress'
param dnsNameLabel string = '${containerGroupName}-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location

resource aciWordPress 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: 'front-end'
        properties: {
          image: 'wordpress:4.9-apache'
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1  
            }      
          }
          ports: [
            {
              port: 80
              protocol: 'TCP'  
            } 
          ]
          environmentVariables: [
            {
              name: 'WORDPRESS_DB_PASSWORD'
              secureValue: mySqlPassword  
            }
            {
              name: 'WORDPRESS_DB_HOST'
              value: '127.0.0.1:3306' 
            } 
          ]   
        }  
      }
      {
        name: 'back-end'
        properties: {
          image: 'mysql:5.7'
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1 
            }
          }
          ports: [
            {
              port: 3306
              protocol: 'TCP' 
            } 
          ]
          environmentVariables: [
            {
              name: 'MYSQL_ROOT_PASSWORD'
              value: mySqlPassword 
            } 
          ]  
        }  
      }  
    ]
    osType: 'Linux'
    restartPolicy: 'OnFailure'
    ipAddress: {
      type: 'Public'
      dnsNameLabel: dnsNameLabel
      ports: [
        {
          port: 80
          protocol: 'TCP' 
        }
      ]    
    }  
  }     
}

output containerIPv4Address string = aciWordPress.properties.ipAddress.ip
