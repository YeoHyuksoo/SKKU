#ifndef STREAMING_HELPER_H
#define STREAMING_HELPER_H 

#include <stdint.h>
#include "ns3/application-container.h"
#include "ns3/node-container.h"
#include "ns3/object-factory.h"
#include "ns3/ipv4-address.h"

namespace ns3 {

class StreamingClientHelper
{
public:
	StreamingClientHelper (Address ip, uint16_t port);
	void SetAttribute (std::string name, const AttributeValue &value);
	ApplicationContainer Install (Ptr<Node> node) const;

private:
	Ptr<Application> InstallPriv (Ptr<Node> node) const;
	ObjectFactory m_factory;
};

class StreamingStreamerHelper
{
public:
	StreamingStreamerHelper (Address ip, uint16_t port);
	void SetAttribute (std::string name, const AttributeValue &value);
	ApplicationContainer Install (Ptr<Node> node) const;

private:
	Ptr<Application> InstallPriv (Ptr<Node> node) const;
	ObjectFactory m_factory;
};

}
#endif
