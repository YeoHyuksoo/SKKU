#ifndef STREAMING_CLIENT_H
#define STREAMING_CLIENT_h

#include "ns3/application.h"
#include "ns3/event-id.h"
#include "ns3/ptr.h"
#include "ns3/address.h"

#include <map>

namespace ns3{

class Socket;
class Packet;

class FrameCheck
{
	public:
		FrameCheck ();
		~FrameCheck ();
		int c[100];
};

class StreamingClient : public Application
{
public:
	static TypeId GetTypeId (void);
	StreamingClient ();
	virtual ~StreamingClient ();

	void FrameConsumer (void);
	void FrameGenerator (void);
	std::map<uint32_t, FrameCheck> m_pChecker;

private:
	virtual void StartApplication (void);
	virtual void StopApplication(void);

	void HandleRead (Ptr<Socket> socket);
	
	uint16_t m_port;
	Ptr<Socket> m_socket;
	Address m_local;

	uint32_t m_seqNumber;
	uint32_t m_fpacketN;
	bool m_lossEnable;
	double m_errorRate;
	
	int Con;
	int noCon;

	// Frame Consumer
	uint32_t m_resume;
	uint32_t m_pause;
	uint32_t m_bufferSize;
	uint32_t m_frameIdx;
	uint32_t m_packetSize;
	int m_frameCnt;
	std::map<uint32_t,bool> m_frameBuffer;
	EventId m_consumEvent;
	Address m_peerAddress;
	double m_consumeTime;

	// Frame Generator
	EventId m_genEvent;
};


}

#endif
