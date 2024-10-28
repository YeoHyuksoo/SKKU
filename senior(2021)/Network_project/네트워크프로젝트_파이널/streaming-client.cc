#include "ns3/log.h"
#include "ns3/ipv4-address.h"
#include "ns3/address-utils.h"
#include "ns3/nstime.h"
#include "ns3/inet-socket-address.h"
#include "ns3/socket.h"
#include "ns3/udp-socket.h"
#include "ns3/simulator.h"
#include "ns3/socket-factory.h"
#include "ns3/packet.h"
#include "ns3/uinteger.h"
#include "ns3/seq-ts-header.h"
#include "ns3/double.h"
#include "ns3/boolean.h"

#include "streaming-client.h"

namespace ns3 {

NS_LOG_COMPONENT_DEFINE ("StreamingClientApplication");

NS_OBJECT_ENSURE_REGISTERED (StreamingClient);

TypeId
StreamingClient::GetTypeId (void)
{
	static TypeId tid = TypeId ("ns3::StreamingClient")
		.SetParent<Application> ()
		.SetGroupName("Applications")
		.AddConstructor<StreamingClient> ()
		.AddAttribute ("RemotePort", "Port on which we listen for incoming packets.",
									 UintegerValue (9),
									 MakeUintegerAccessor (&StreamingClient::m_port),
									 MakeUintegerChecker<uint16_t> ())
    .AddAttribute ("RemoteAddress", 
                   "The destination Address of the outbound packets",
                   AddressValue (),
                   MakeAddressAccessor (&StreamingClient::m_peerAddress),
                   MakeAddressChecker ())
    .AddAttribute ("PacketSize", 
                   "The packet size",
									 UintegerValue (100),
									 MakeUintegerAccessor (&StreamingClient::m_packetSize),
									 MakeUintegerChecker<uint32_t> ())
    .AddAttribute ("BufferSize", 
                   "The frame buffer size",
									 UintegerValue (40),
									 MakeUintegerAccessor (&StreamingClient::m_bufferSize),
									 MakeUintegerChecker<uint32_t> ())
    .AddAttribute ("PauseSize", 
                   "The pause size for the frame buffer",
									 UintegerValue (30),
									 MakeUintegerAccessor (&StreamingClient::m_pause),
									 MakeUintegerChecker<uint32_t> ())
    .AddAttribute ("ResumeSize", 
                   "The resume size for the frame buffer",
									 UintegerValue (5),
									 MakeUintegerAccessor (&StreamingClient::m_resume),
									 MakeUintegerChecker<uint32_t> ())
    .AddAttribute ("FramePackets", 
                   "# of packets in forms of a frame",
                   UintegerValue (100),
                   MakeUintegerAccessor (&StreamingClient::m_fpacketN),
                   MakeUintegerChecker<uint32_t> ())
    .AddAttribute ("ConsumeStartTime", 
                   "Consumer Start Time",
                   DoubleValue (1.1),
                   MakeDoubleAccessor (&StreamingClient::m_consumeTime),
                   MakeDoubleChecker<double> ())
    .AddAttribute ("PacketLossEnable", 
                   "Forced Packet Loss on/off",
                   BooleanValue (false),
                   MakeBooleanAccessor (&StreamingClient::m_lossEnable),
                   MakeBooleanChecker ())
    .AddAttribute ("ErrorRate", 
                   "ErrorRate",
                   DoubleValue (0.01),
                   MakeDoubleAccessor (&StreamingClient::m_errorRate),
                   MakeDoubleChecker<double> ())
	
		;
	return tid;
}

StreamingClient::StreamingClient ()
{
	NS_LOG_FUNCTION (this);
	m_seqNumber = 0;
	m_consumEvent = EventId ();
	m_genEvent = EventId ();
	m_frameCnt = 0;
	m_frameIdx = 0;
	Con = 0;
	noCon = 0;
}

StreamingClient::~StreamingClient ()
{
	NS_LOG_FUNCTION (this);
	m_socket = 0;
}

void
StreamingClient::FrameConsumer (void)
{
	// Frame Consume
	if (m_frameCnt >= 0)
	{
		if (m_frameBuffer.find (m_frameIdx) != m_frameBuffer.end() )
		{
			m_frameCnt -= 1;
			m_frameBuffer.erase(m_frameIdx);
			NS_LOG_INFO("FrameConsumerLog::Consume" << m_frameIdx);
			Con++;
		}
		else if (m_frameCnt == 0)
		{
			NS_LOG_INFO("FrameConsumerLog::NoConsume"<< m_frameIdx);
			noCon++;
		}
		else
		{
			NS_LOG_INFO("FrameConsumerLog::NoConsume"<< m_frameIdx);
			noCon++;
		}
		//NS_LOG_INFO(Simulator::Now ().GetSeconds () << " " << m_frameCnt);
		//NS_LOG_INFO("NoConsume / Consume (%): " << noCon << '/' << Con << "->" << (float)noCon/(float)Con * 100);
	}
	else if (m_frameCnt < 0)
	{
		NS_LOG_INFO("FrameCountError!");
		exit (1);
	}
	m_frameIdx += 1;

	// FrameBufferCheck
	if (m_frameCnt >= (int)m_pause)
	{
		Ptr<Packet> p;
		p = Create<Packet> (m_packetSize);
		SeqTsHeader header;
		header.SetSeq (-2);
		p->AddHeader (header);

		Ptr<UdpSocket> udpSocket = DynamicCast<UdpSocket> (m_socket);
		udpSocket->SendTo (p, 0, m_peerAddress);
	}
	else if (m_frameCnt <= (int)m_resume)
	{
		Ptr<Packet> p;
		p = Create<Packet> (m_packetSize);
		SeqTsHeader header;
		header.SetSeq (-1);
		p->AddHeader (header);

		Ptr<UdpSocket> udpSocket = DynamicCast<UdpSocket> (m_socket);
		udpSocket->SendTo (p, 0, m_peerAddress);
	}

	m_consumEvent = Simulator::Schedule ( Seconds ((double)1.0/60), &StreamingClient::FrameConsumer, this);
}

uint32_t frame_max = 0;
int losspacket[1000] = {0};
int losscnt = 0;

void 
StreamingClient::FrameGenerator (void)
{
	if (m_frameCnt < (int)m_bufferSize)
	{
		std::map<uint32_t,FrameCheck>::iterator iter;

		for (iter = m_pChecker.begin(); iter != m_pChecker.end();)
		{
			uint32_t idx = iter->first;

			if (idx < m_frameIdx)
			{
				m_pChecker.erase(iter++);
			}
			else
			{
				uint32_t count = 0;
				for (uint32_t i=0; i<m_fpacketN; i++)
				{
					FrameCheck c = iter->second;
					if (c.c[i] == 1)
						count++;
					else{
						if(idx < frame_max){
							losspacket[losscnt++] = idx*100 + i;
							//NS_LOG_INFO("packet #" << idx*100 + i << "goes to loss packet");
						}
					}
				}

				if (count == m_fpacketN)
				{
					m_pChecker.erase(iter++);
					m_frameCnt++;
					m_frameBuffer.insert({idx, true});
					//NS_LOG_INFO("make frame #" << idx);
					frame_max = idx;
				}
				else
				{
					++iter;
				}
			}
		}
	}

	m_genEvent = Simulator::Schedule ( Seconds ((double)1.0/20), &StreamingClient::FrameGenerator, this);
}


void 
StreamingClient::StartApplication (void)
{
	NS_LOG_FUNCTION (this);
	
	if (m_socket == 0)
  {
    TypeId tid = TypeId::LookupByName ("ns3::UdpSocketFactory");
    m_socket = Socket::CreateSocket (GetNode (), tid);
    InetSocketAddress local = InetSocketAddress (Ipv4Address::GetAny (), m_port);
    if (m_socket->Bind (local) == -1)
    {
			NS_FATAL_ERROR ("Failed to bind socket");
    }
    if (addressUtils::IsMulticast (m_local))
		{
			Ptr<UdpSocket> udpSocket = DynamicCast<UdpSocket> (m_socket);
      if (udpSocket)
      {
        // equivalent to setsockopt (MCAST_JOIN_GROUP)
        udpSocket->MulticastJoinGroup (0, m_local);
      }
      else
      {
        NS_FATAL_ERROR ("Error: Failed to join multicast group");
      }
    }
  }

	m_socket->SetRecvCallback (MakeCallback (&StreamingClient::HandleRead, this));
	m_consumEvent = Simulator::Schedule ( Seconds (m_consumeTime), &StreamingClient::FrameConsumer, this);
	FrameGenerator ();
}

void
StreamingClient::StopApplication ()
{
	NS_LOG_FUNCTION (this);
	if (m_socket != 0)
  {
		m_socket->Close ();
    m_socket->SetRecvCallback (MakeNullCallback<void, Ptr<Socket> > ());
  }
  
	Simulator::Cancel (m_consumEvent);
}

void StreamingClient::HandleRead (Ptr<Socket> socket)
{
	NS_LOG_FUNCTION (this << socket);

	Ptr<Packet> packet;
	Address from;
	Address localAddress;
	while ((packet = socket->RecvFrom (from)))
	{
		socket->GetSockName (localAddress);
		

		// Packet Log
		/*
		if (InetSocketAddress::IsMatchingType (from))
		{
			NS_LOG_INFO ("At time " << Simulator::Now ().GetSeconds () << "s client received " << packet->GetSize () << " bytes from " <<
					InetSocketAddress::ConvertFrom (from).GetIpv4 () << " port " <<
					InetSocketAddress::ConvertFrom (from).GetPort ());
		}
		*/

		if (m_lossEnable)
		{
			double prob = (double)rand() / RAND_MAX;
			if (prob <= m_errorRate){
			      	packet->RemoveAllPacketTags ();
			      	packet->RemoveAllByteTags ();
				socket->SendTo (packet, 0, from);
				//NS_LOG_INFO("packet loss!");
				continue;
			}
		}
		
		SeqTsHeader seqTs;
		packet->RemoveHeader (seqTs);
		int seqN = seqTs.GetSeq();
		if (seqN<0){
			seqTs.SetSeq (seqN*-1);
			packet->AddHeader (seqTs);
			packet->RemoveAllPacketTags ();
		      	packet->RemoveAllByteTags ();
			socket->SendTo (packet, 0, from);
			//NS_LOG_INFO("packet loss!" << seqN);
			continue;
		}
		else if(seqN<int((m_frameIdx-1)*100)){
			//NS_LOG_INFO("Useless packet!");
			continue;
		}
		
		//NS_LOG_INFO("current seqN:" << seqN);
		int frameIdx = seqN/m_fpacketN;
		seqN = seqN - frameIdx * m_fpacketN;

		if (m_pChecker.size() < (m_bufferSize * 2 * m_fpacketN) )
		{
			if (m_pChecker.find(frameIdx) != m_pChecker.end())
			{
				FrameCheck tc = m_pChecker[frameIdx];
				tc.c[seqN] = 1;
				m_pChecker[frameIdx]=tc;
			}
			else
			{
				FrameCheck c;
				c.c[seqN] = 1;
				m_pChecker.insert({frameIdx,c});
			}
		}
		
		if (losscnt!=0){
			for(int i=0;i<losscnt;i++){
				SeqTsHeader seqTs;
				packet->RemoveHeader (seqTs);
				seqTs.SetSeq (losspacket[i]);
				packet->AddHeader (seqTs);
				packet->RemoveAllPacketTags ();
			      	packet->RemoveAllByteTags ();
			      	//NS_LOG_INFO("need to retransmit packet #" << losspacket[i]);
				socket->SendTo (packet, 0, from);
			}
			losscnt=0;
		}
		
	}
}

FrameCheck::FrameCheck ()
{
	for (uint32_t i=0; i<100; i++)
		c[i] = 0;
}

FrameCheck::~FrameCheck()
{
}

}
