#include "streaming-helper.h"
#include "streaming-streamer.h"
#include "streaming-client.h"
#include "ns3/uinteger.h"
#include "ns3/names.h"

namespace ns3 {


// Clinet
StreamingClientHelper::StreamingClientHelper (Address address, uint16_t port)
{
	m_factory.SetTypeId (StreamingClient::GetTypeId());
	SetAttribute ("RemoteAddress", AddressValue (address));
	SetAttribute ("RemotePort", UintegerValue (port));
}

void
StreamingClientHelper::SetAttribute (std::string name, const AttributeValue &value)
{
	m_factory.Set (name, value);
}

ApplicationContainer
StreamingClientHelper::Install (Ptr<Node> node) const
{
	return ApplicationContainer (InstallPriv (node));
}

Ptr<Application>
StreamingClientHelper::InstallPriv (Ptr<Node> node) const
{
	Ptr<Application> app = m_factory.Create<StreamingClient> ();
	node->AddApplication (app);
	
	return app;
}


// Streamer
StreamingStreamerHelper::StreamingStreamerHelper (Address address, uint16_t port)
{
	m_factory.SetTypeId (StreamingStreamer::GetTypeId ());
	SetAttribute ("RemoteAddress", AddressValue (address));
	SetAttribute ("RemotePort", UintegerValue (port));
}

void 
StreamingStreamerHelper::SetAttribute (std::string name, const AttributeValue &value)
{
	m_factory.Set (name, value);
}

ApplicationContainer
StreamingStreamerHelper::Install (Ptr<Node> node) const
{
	return ApplicationContainer (InstallPriv (node));
}

Ptr<Application>
StreamingStreamerHelper::InstallPriv (Ptr<Node> node) const
{
	Ptr<Application> app = m_factory.Create<StreamingStreamer> ();
	node->AddApplication (app);

	return app;
}

}
