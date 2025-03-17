/*
To create an OTAA end Device already activated with its session keys.
We need to create an OTAA end-device with the root key, update it (PUT) with the session keys and the devAddr in ABP.
Then update it again to switch it back to OTAA. 
*/

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


const getProfile = async () => {
    const response = await fetch(`${API_BASE_URL}/urprofiles`, {
        method: "GET",
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${API_KEY_MILESIGHT}`
        },
        params: {
            "limit": 10,
            "offset": 0,
            "organizationID": 1,
            "applicationID": 14
        }
    });
    const data = await response.json();
    return data;
}




const addDevices = async () => {
    let devices =
    {
        "devEUI": "ECDB86FFFD5A42F3",
        "name": "devicetest",
        "applicationID": "14",
        "description": "test",
        "profileID": "512e21d9-81c1-4bf9-872c-1f6bb9ed5ac4",
        "skipFCntCheck": false,
        "appKey": "EF8BC873F08B7F31763E1347C9FBD3AF",
        /*"devAddr": "00000001",
        "nwkSKey": "00000000000000010000000000000001",
        "appSKey": "00000000000000010000000000000001",*/
        "fCntUp": 0,
        "fCntDown": 0,
        "fPort": 85,
        "payloadCodecID": "0",
    };

    const response = await fetch(`${API_BASE_URL}/urdevices`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${API_KEY_MILESIGHT}`
        },
        body: JSON.stringify(devices)
    });
    const data = await response.json();
    console.log(data);
}


const updateDevice = async () => {
    let device =
    {
        "name": "devicetest",
        "description": "test",
        //"profileID": "22a449f1-2e7d-4028-9d3b-358328136c7e",    // abp
        "profileID": "512e21d9-81c1-4bf9-872c-1f6bb9ed5ac4", // 0taa
        "skipFCntCheck": true,
        "appKey": "EF8BC873F08B7F31763E1347C9FBD3AF",
        "devAddr": "260BDA16",
        "nwkSKey": "95D23D352D6F9D260CD6AD1DD65A8568",
        "appSKey": "9A452718B5BD236D81C8339AC19E19D0",
        "fCntUp": 0,
        "fCntDown": 10,
        "fPort": 85,
        "payloadCodecID": "0",
    };
                                  https://192.168.1.148:8080/api
    const response = await fetch(`${API_BASE_URL}/urdevices/ECDB86FFFD5A42F3`, {
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${API_KEY_MILESIGHT}`
        },
        body: JSON.stringify(device)
    });
    const data = await response.json();
    console.log(data);
}

// Function to save results to file
const saveToFile = async (data) => {
    try {
        await writeFile("milesight_ug65_profiles.json", JSON.stringify(data, null, 2), "utf8");
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

        /* const profiles = await getProfile();
         console.log("Profiles:", profiles);*/

      //  await addDevices();
        await updateDevice();

        const result = {
            apiKey: API_KEY_MILESIGHT,
            gatewayEui: GATEWAY_EUI,
            profiles
        };


        await saveToFile(result);
    } catch (error) {
        console.error("Error:", error.message);
    }
};

main();