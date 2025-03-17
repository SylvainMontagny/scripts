import grpc from "@grpc/grpc-js";
import { createRequire } from "module";

const require = createRequire(import.meta.url);
const { DeviceServiceClient } = require("@chirpstack/chirpstack-api/api/device_grpc_pb");
const { GetDeviceActivationRequest } = require("@chirpstack/chirpstack-api/api/device_pb");

// Configuration
const SERVER_ADDRESS = "server1.univ-lorawan.fr:8080"; // Replace with your ChirpStack server address
const API_TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjaGlycHN0YWNrIiwiaXNzIjoiY2hpcnBzdGFjayIsInN1YiI6IjU4YzhmM2MwLWI3YTEtNGE4OS04ODZiLTkxMjBkMmZjZTdkYiIsInR5cCI6ImtleSJ9.0mbbqyqCywLoJdw1I-9TeHgOkJro-r1YS4DMyzwKtw4";
const DEV_EUI = "ecdb86fffd300473"; // Replace with the DevEUI of the device you want to check

// Create gRPC metadata and credentials
const metadata = new grpc.Metadata();
metadata.set("authorization", `Bearer ${API_TOKEN}`);

// Create gRPC client
const deviceClient = new DeviceServiceClient(SERVER_ADDRESS, grpc.credentials.createInsecure());

// Function to get device activation status
async function getDeviceActivation(devEui) {
  return new Promise((resolve, reject) => {
    const request = new GetDeviceActivationRequest();
    request.setDevEui(devEui);

    deviceClient.getActivation(request, metadata, (err, response) => {
      if (err) {
        return reject(new Error(`Failed to get device activation: ${err.message}`));
      }
      resolve(response);
    });
  });
}

// Main execution
(async () => {
  try {
    const activation = await getDeviceActivation(DEV_EUI);
    console.log("Device Activation Details:", activation.toObject());
  } catch (error) {
    console.error("Error:", error.message);
  }
})();