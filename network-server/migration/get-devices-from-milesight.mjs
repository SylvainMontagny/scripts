import { writeFile } from "fs/promises";

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"; // Disable SSL verification globally

const API_BASE_URL = "https://192.168.1.148:8080/api";
const LOGIN_CREDENTIALS = {
  username: "apiuser",
  password: "univ-lorawan"
};

let API_KEY_MILESIGHT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJsb3JhLWFwcC1zZXJ2ZXIiLCJleHAiOjE3NDAxNjkwNjgsImlzcyI6ImxvcmEtYXBwLXNlcnZlciIsIm5iZiI6MTc0MDA4MjY2OCwic3ViIjoidXNlciIsInVzZXJuYW1lIjoiYWRtaW4ifQ.FCEXh32bOD8_TlTB05lF5HTL_VnTP79J_DlxJGEmyGs";
let GATEWAY_EUI = "24E124FFFEF8E6D8";

// Function to fetch authentication token with error handling
const getAuthToken = async () => {
  const response = await fetch(`${API_BASE_URL}/internal/login`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: JSON.stringify(LOGIN_CREDENTIALS)
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(`Login failed: ${data.error || "Unknown error"}`);
  }

  if (!data.jwt) {
    throw new Error(`Authentication failed: ${data.error || "Invalid response format"}`);
  }

  API_KEY_MILESIGHT = data.jwt;
};

// Function to fetch gateway information
const getGatewayEui = async () => {
  const response = await fetch(`${API_BASE_URL}/packet-forwarder/network-servers`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${API_KEY_MILESIGHT}`
    }
  });

  const data = await response.json();
  GATEWAY_EUI = data.gatewayEui;
};

// Function to fetch devices
const getDevices = async () => {
  const response = await fetch(`${API_BASE_URL}/devices?limit=100&offset=0`, {
    method: "GET",
    headers: {
      "Accept": "application/json",
      "Authorization": `Bearer ${API_KEY_MILESIGHT}`
    }
  });

  const data = await response.json();
  return data.devices;
};

// Function to save results to file
const saveToFile = async (data) => {
  try {
    await writeFile("milesight_ug65_devices.json", JSON.stringify(data, null, 2), "utf8");
    console.log("Results saved to milesight_ug65_devices.json");
  } catch (error) {
    console.error("Failed to write file:", error.message);
  }
};

// Main execution with error handling
const main = async () => {
  try {
    await getAuthToken();
    console.log("API Key:", API_KEY_MILESIGHT);

    await getGatewayEui();
    console.log("Gateway EUI:", GATEWAY_EUI);

    const devices = await getDevices();
    console.log("Devices:", devices);

    const result = {
      apiKey: API_KEY_MILESIGHT,
      gatewayEui: GATEWAY_EUI,
      devices
    };

    await saveToFile(result);
  } catch (error) {
    console.error("Error:", error.message);
  }
};

main();