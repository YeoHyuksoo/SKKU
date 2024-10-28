#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/wifi-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/internet-module.h"
#include "ns3/mobility-module.h"

#include "streaming-helper.h"
#include "streaming-streamer.h"
#include "streaming-client.h"

using namespace ns3;
NS_LOG_COMPONENT_DEFINE ("final");

int
main (int argc, char *argv[])
{
	srand(time(NULL));

  LogComponentEnable("StreamingClientApplication", LOG_LEVEL_INFO);
	//LogComponentEnable("StreamingStreamerApplication", (LogLevel)(LOG_LEVEL_INFO|LOG_PREFIX_TIME|LOG_PREFIX_NODE));

	/*
	 * ========================
	 *  Changeable Parameters
	 * ========================
	 *          Start
	 * ========================
	 */

	// Forced Packet Error Generate
	double errorRate = 5; // 0 ~ 100 %
	errorRate = errorRate / 100;
	bool packetLossEnable = true; // on/off

	// Server Configuration
	uint32_t sendFPS = 90; 

	// Client Configuration
	uint32_t bufferSize = 40;
	uint32_t pauseSize = 30;
	uint32_t resumeSize = 25;
	double consumeStartTime = 1.1; // Seconds

	/*
	 * =======================
	 *          End
	 * =======================
	 */

	uint32_t payloadSize = 1472;
	bool tcp = false;
	uint32_t fpacketN = 100;
	double simulationTime = 10;
	CommandLine cmd;

	if (tcp)
	{
		payloadSize = 1448;
		Config::SetDefault ("ns3::TcpSocket::SegmentSize", UintegerValue (payloadSize));
	}

	uint32_t antenna = 3;
	// Node Create
	NodeContainer wifiStaNode;
	wifiStaNode.Create (1);
	NodeContainer wifiApNode;
	wifiApNode.Create (1);

	// PHY layer Create
	YansWifiChannelHelper channel = YansWifiChannelHelper::Default ();
	YansWifiPhyHelper phy = YansWifiPhyHelper::Default ();
	phy.SetChannel (channel.Create ());
	phy.Set ("ChannelWidth", UintegerValue (80));
	phy.Set ("Antennas", UintegerValue (antenna));
	phy.Set ("MaxSupportedTxSpatialStreams", UintegerValue (antenna));
	phy.Set ("MaxSupportedRxSpatialStreams", UintegerValue (antenna));
	phy.Set ("RxNoiseFigure", DoubleValue (45.0));

	// Wifi Setting
	WifiHelper wifi;
	wifi.SetStandard (WIFI_PHY_STANDARD_80211ac);
	wifi.SetRemoteStationManager ("ns3::ConstantRateWifiManager", 
																"DataMode", StringValue ("VhtMcs9"),
																"ControlMode", StringValue ("VhtMcs0"));
	// Mac Setting
	WifiMacHelper mac;
	Ssid ssid = Ssid ("final");

	// STA Install
	mac.SetType ("ns3::StaWifiMac",
							 "Ssid", SsidValue (ssid));
	NetDeviceContainer staDevice;
	staDevice = wifi.Install (phy, mac, wifiStaNode);

	// AP Install
	mac.SetType ("ns3::ApWifiMac",
							"EnableBeaconJitter", BooleanValue (false),
							"Ssid", SsidValue (ssid));
	NetDeviceContainer apDevice;
	apDevice = wifi.Install (phy, mac, wifiApNode);

	// Mobility Setting 
	MobilityHelper mobility;
	Ptr<ListPositionAllocator> positionAlloc = CreateObject<ListPositionAllocator> ();

	positionAlloc->Add (Vector (0.0, 0.0, 0.0));
	positionAlloc->Add (Vector (1.0, 0.0, 0.0));
	mobility.SetPositionAllocator (positionAlloc);

	mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");

	mobility.Install (wifiApNode);
	mobility.Install (wifiStaNode);

	// Internet Stack Install
	InternetStackHelper stack;
	stack.Install (wifiApNode);
	stack.Install (wifiStaNode);

	Ipv4AddressHelper address;
	address.SetBase ("192.168.1.0", "255.255.255.0");
	Ipv4InterfaceContainer staNodeInterface;
	Ipv4InterfaceContainer apNodeInterface;

	staNodeInterface = address.Assign (staDevice);
	apNodeInterface = address.Assign (apDevice);

	// Application Stack Install
	StreamingStreamerHelper streamer ( staNodeInterface.GetAddress(0), 9);
	streamer.SetAttribute ("PacketSize", UintegerValue (payloadSize));
	streamer.SetAttribute ("FramePackets", UintegerValue (fpacketN));
	streamer.SetAttribute ("StreamingFPS", UintegerValue (sendFPS));
	streamer.SetAttribute ("PacketLossEnable", BooleanValue (packetLossEnable));
	streamer.SetAttribute ("ErrorRate", DoubleValue (errorRate));
	ApplicationContainer streamerApp = streamer.Install (wifiApNode.Get (0));
	streamerApp.Start (Seconds (1.0));
	streamerApp.Stop (Seconds (simulationTime));

	StreamingClientHelper client (InetSocketAddress(apNodeInterface.GetAddress(0), 49153), 9);
	client.SetAttribute ("PacketSize", UintegerValue (payloadSize));
	client.SetAttribute ("FramePackets", UintegerValue (fpacketN));
	client.SetAttribute ("BufferSize", UintegerValue (bufferSize));
	client.SetAttribute ("PauseSize", UintegerValue (pauseSize));
	client.SetAttribute ("ResumeSize", UintegerValue (resumeSize));
	client.SetAttribute ("ConsumeStartTime", DoubleValue (consumeStartTime));
	client.SetAttribute ("PacketLossEnable", BooleanValue (packetLossEnable));
	client.SetAttribute ("ErrorRate", DoubleValue (errorRate));
	ApplicationContainer clientApp = client.Install (wifiStaNode.Get (0));
	clientApp.Start (Seconds (0.0));
	clientApp.Stop (Seconds (simulationTime));

	// Simulation Start
	Simulator::Stop (Seconds (simulationTime));
	Simulator::Run ();
	Simulator::Destroy ();
	return 0;
}
