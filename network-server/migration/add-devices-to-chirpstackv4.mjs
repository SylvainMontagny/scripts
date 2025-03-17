import grpc from "@grpc/grpc-js";
import { createRequire } from "module";
import fs from "fs";

const require = createRequire(import.meta.url);

const { TenantServiceClient } = require("@chirpstack/chirpstack-api/api/tenant_grpc_pb");
const { ListTenantsRequest } = require("@chirpstack/chirpstack-api/api/tenant_pb");
const { ApplicationServiceClient } = require("@chirpstack/chirpstack-api/api/application_grpc_pb");
const { ListApplicationsRequest } = require("@chirpstack/chirpstack-api/api/application_pb");
const { DeviceProfileServiceClient } = require("@chirpstack/chirpstack-api/api/device_profile_grpc_pb");
const { ListDeviceProfilesRequest } = require("@chirpstack/chirpstack-api/api/device_profile_pb");
const { DeviceServiceClient } = require("@chirpstack/chirpstack-api/api/device_grpc_pb");
const { CreateDeviceRequest, Device } = require("@chirpstack/chirpstack-api/api/device_pb");
const { CreateDeviceKeysRequest, DeviceKeys } = require("@chirpstack/chirpstack-api/api/device_pb");
const { ActivateDeviceRequest, DeviceActivation } = require("@chirpstack/chirpstack-api/api/device_pb");

const SERVER_ADDRESS = "server1.univ-lorawan.fr:8080";
const API_TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjaGlycHN0YWNrIiwiaXNzIjoiY2hpcnBzdGFjayIsInN1YiI6IjU4YzhmM2MwLWI3YTEtNGE4OS04ODZiLTkxMjBkMmZjZTdkYiIsInR5cCI6ImtleSJ9.0mbbqyqCywLoJdw1I-9TeHgOkJro-r1YS4DMyzwKtw4";

const metadata = new grpc.Metadata();
metadata.set("authorization", `Bearer ${API_TOKEN}`);

const tenantClient = new TenantServiceClient(SERVER_ADDRESS, grpc.credentials.createInsecure());
const applicationClient = new ApplicationServiceClient(SERVER_ADDRESS, grpc.credentials.createInsecure());
const deviceProfileClient = new DeviceProfileServiceClient(SERVER_ADDRESS, grpc.credentials.createInsecure());
const deviceClient = new DeviceServiceClient(SERVER_ADDRESS, grpc.credentials.createInsecure());

// Load JSON files
const devicesFile = "milesight_ug65_devices.json";
const modelsFile = "LoRaWAN-end-devices.json";

const devicesData = JSON.parse(fs.readFileSync(devicesFile));
const modelsData = JSON.parse(fs.readFileSync(modelsFile));

// Retrieve tenantId dynamically
async function getTenantId() {
  return new Promise((resolve, reject) => {
    const request = new ListTenantsRequest();
    request.setLimit(100);
    request.setOffset(0);

    tenantClient.list(request, metadata, (err, response) => {
      if (err) return reject(new Error(`Failed to retrieve tenants: ${err.message}`));

      const tenants = response.getResultList();
      if (!tenants.length) return reject(new Error("No tenants found!"));

      resolve(tenants[0].getId());
    });
  });
}

// Retrieve applicationId for "tyvengate"
async function getApplicationId(tenantId) {
  return new Promise((resolve, reject) => {
    const request = new ListApplicationsRequest();
    request.setTenantId(tenantId);
    request.setLimit(100);
    request.setOffset(0);

    applicationClient.list(request, metadata, (err, response) => {
      if (err) return reject(new Error(`Failed to retrieve applications: ${err.message}`));

      const apps = response.getResultList();
      const app = apps.find((a) => a.getName() === "application");

      if (!app) return reject(new Error("Application 'application' not found!"));
      resolve(app.getId());
    });
  });
}

// Retrieve device profiles
async function getDeviceProfiles(tenantId) {
  return new Promise((resolve, reject) => {
    const request = new ListDeviceProfilesRequest();
    request.setTenantId(tenantId);
    request.setLimit(100);
    request.setOffset(0);

    deviceProfileClient.list(request, metadata, (err, response) => {
      if (err) return reject(new Error(`Failed to retrieve device profiles: ${err.message}`));

      const profiles = response.getResultList().reduce((map, profile) => {
        map[profile.getName()] = profile.getId();
        return map;
      }, {});

      resolve(profiles);
    });
  });
}

// Map models to brands
const brandModelMap = modelsData.reduce((map, entry) => {
  map[entry.model] = entry.brand;
  return map;
}, {});

// Add multiple devices
async function addDevices(applicationId, deviceProfiles) {
  for (const device of devicesData.devices) {
    try {
      const modelName = device.name.split("_")[0];
      const brand = brandModelMap[modelName] || "Unknown";
      const newName = `${brand}_${device.name}`;
      const deviceProfileId = deviceProfiles[`${brand}_${modelName}`];

      /*if (!deviceProfileId) {
        console.warn(`⚠️ Skipping device ${newName}: Device profile not found for ${brand}_${modelName}`);
        continue;
      }*/

      console.log(`🟢 Adding device: ${newName}`);

      // Create device
      const createDeviceRequest = new CreateDeviceRequest();
      const newDevice = new Device();
      newDevice.setDevEui(device.devEUI);
      newDevice.setName(newName);
      newDevice.setApplicationId(applicationId);
      newDevice.setDeviceProfileId(deviceProfileId);
      newDevice.setDeviceProfileId('0ddc0229-2c9a-4a12-821d-c9a4546e2607');
      createDeviceRequest.setDevice(newDevice);

      await new Promise((resolve, reject) => {
        deviceClient.create(createDeviceRequest, metadata, (err) => {
          if (err) return reject(new Error(`Failed to create device: ${err.message}`));
          console.log(`✅ Device ${newName} added`);
          resolve();
        });
      });

      // Add DeviceKeys
      const createDeviceKeysRequest = new CreateDeviceKeysRequest();
      const deviceKeys = new DeviceKeys();
      deviceKeys.setDevEui(device.devEUI);
      deviceKeys.setNwkKey(device.appKey);
      createDeviceKeysRequest.setDeviceKeys(deviceKeys);

      await new Promise((resolve, reject) => {
        deviceClient.createKeys(createDeviceKeysRequest, metadata, (err) => {
          if (err) return reject(new Error(`Failed to set device keys: ${err.message}`));
          console.log(`🔑 DeviceKeys set for ${newName}`);
          resolve();
        });
      });

      // Perform Device Activation
      const activateDeviceRequest = new ActivateDeviceRequest();
      const deviceActivation = new DeviceActivation();
      deviceActivation.setDevEui(device.devEUI);
      deviceActivation.setDevAddr(device.devAddr);
      deviceActivation.setAppSKey(device.appSKey);
      deviceActivation.setNwkSEncKey(device.nwkSKey);
      deviceActivation.setSNwkSIntKey(device.nwkSKey);
      deviceActivation.setFNwkSIntKey(device.nwkSKey);
      deviceActivation.setFCntUp(device.fCntUp);
      deviceActivation.setNFCntDown(device.fCntDown);
      activateDeviceRequest.setDeviceActivation(deviceActivation);

      await new Promise((resolve, reject) => {
        deviceClient.activate(activateDeviceRequest, metadata, (err) => {
          if (err) return reject(new Error(`Failed to activate device: ${err.message}`));
          console.log(`🚀 Device ${newName} activated successfully`);
          resolve();
        });
      });

    } catch (error) {
      console.error(`❌ Error processing device ${device.name}: ${error.message}`);
    }
  }
}

// Main execution
(async () => {
  try {
    const tenantId = await getTenantId();
    console.log(`🔹 Retrieved tenantId: ${tenantId}`);

    const applicationId = await getApplicationId(tenantId);
    console.log(`🔹 Retrieved applicationId: ${applicationId}`);

    const deviceProfiles = await getDeviceProfiles(tenantId);
    console.log(`🔹 Retrieved device profiles: ${JSON.stringify(deviceProfiles)}`);

    await addDevices(applicationId, deviceProfiles);
    console.log("✅ All devices processed successfully.");
  } catch (error) {
    console.error("❌ Error:", error.message);
  }
})();