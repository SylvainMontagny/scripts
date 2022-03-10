ACTIVATION_MODE="OTAA"       # ABP or OTAA    # Selection of Activation Method
SEND_BY_PUSH_BUTTON="false" # true or false  # Sending method (Time or Push Button)
FRAME_DELAY="10000"         # Time in ms     # Time between 2 frames (Minimum 7000)
DATA_RATE="5"               # Number [0;5]   # Data Rate : 5=SF7BW125  0=SF12BW125
ADAPTIVE_DR="false"         # true or false  # Enable ADR (if true)
CONFIRMED="false"           # true or false  # Unconfirmed (if false) or Confirmed (if true) messages
PORT="1"                    # Number [0;199] # Application Port number

# ABP Activation Mode
DEVADDR="MY_DEV_ADDR"
NWKSKEY="MY_NW_S_KEY"
APPSKEY="MY_APP_S_KEY"

# OTAA Activation Mode
APPEUI="00000000000000000000000000000000"
APPKEY="12132145542665552363556632526565"

