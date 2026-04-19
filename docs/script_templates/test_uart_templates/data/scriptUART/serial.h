
const uint64 UART_MILLIS = 1000000000;

IoPin@  txPin = component.getPin("Tx");
IoPin@  rxPin = component.getPin("Rx");

enum pinModes{
    serial_undef=0, 
    serial_input,
    serial_openCo,
    serial_output,
    serial_source
}

bool serial_busy = false;

uint baudrate = 9600;
array<int> sendbuf;
array<int> rcvbuf;

void serial_reset( uint64 BAUD ) // Executed at Simulation start
{
	print("Serial reset()");
	
	baudrate = BAUD;

	sendbuf.resize(0);
	rcvbuf.resize(0);
	serial_busy = true;
	
	txPin.setOutState( true );
	txPin.setPinMode( serial_output );
	// rxPin.setPinMode( serial_input );
	
	Uart0.setBaudRate( baudrate );		
	serial_busy = false;
}

bool serial_polling() {
	if (!serial_busy) {
		if (sendbuf.length() > 0) {
			serial_busy = true;
			int c = sendbuf[0];
			sendbuf.removeAt(0);
			Uart0.sendByte(c);
			return true;
		}
	}
	return false;
}

void serial_sendString( string &in txt ) {
	for (uint i=0; i<txt.length(); i++) {
		sendbuf.insertLast(txt[i]);
	}
}

void serial_received( uint data ) {
	rcvbuf.insertLast(data);
}

int serial_available() {
	return rcvbuf.length();
}

string serial_readLine() {
	string txt;
	while (serial_available() > 0) {
		int c = rcvbuf[0];
		rcvbuf.removeAt(0);
		if ((c != 0x0A) && (c != 0x0C)) {
			txt += codeToChar(c);
		} else {
			break;
		}
	}
	return txt;		
}

// Créez une chaîne contenant tous les caractères ASCII (simplifié pour l'exemple)
string asciiTable = 
    "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F" +
    "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F" +
    " !\"#$%&'()*+,-./0123456789:;<=>?@" +
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`" +
    "abcdefghijklmnopqrstuvwxyz{|}~\x7F";

// Fonction de conversion
string codeToChar(int code)
{
    if (code >= 0 && code < 128)
        return asciiTable.substr(code, 1); // Extrait le caractère à la position `code`
    else
        return "?"; // Gestion des codes invalides
}

void frameSent( uint data )
{
    // print( "frameSent "+data );
	serial_busy = false;
}

void byteReceived( uint data )
{
    // print( "byte Received "+data );
	serial_received(data);
}
