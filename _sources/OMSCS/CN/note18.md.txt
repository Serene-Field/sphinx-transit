# Computer Network 18 | VoIP and Live/On-Demand Streaming 

### 1. VoIP

#### (1) Common Multimedia Applications

The different kinds of multimedia applications can be organized into three major categories. These are,

- streaming stored audio and video: e.g. Youtube
    - streamed
    - interative
    - continuous olayout
- conversational voice and video over IP (VoIP): e.g. Skype
    - delay-sensitive
    - loss-tolerant
- streaming live audio and video: e.g. Twitch
    - many simultaneous users
    - delay-sensitive

#### (2) VoIP

VoIP is a technique used in conversational voice over IP. Since internet packet transmission is based on best effort and it makes no promises that a datagram will actually make it to its final destination, or even on time.

In this topic, we’ll discuss three major topics in VoIP,

- encoding
- signaling
- QoS

#### (3) VoIP Topic 1: Audio Encoding

Analog audio by nature is represented as a continuous wave, but digital data by nature is discrete. Therefore, all digital representations of analog audio are only approximations. Generally speaking, audio is **encoded** by taking many of samples per second, and then rounding each sample’s value to a discrete number within a particular range. This rounding to a discrete number is
called **quantization**.

There are three major categories of encoding schemes and different characteristics and tradeoffs,

- narrowband
- broadband
- multimode (for both narrowband and broadband)

For VoIP, the important thing is that we want to still be
able to understand the speech and the words that are being said, while at the same time still using as little bandwidth as possible.

Audio can also be compressed but there are some tradeoffs there too. We will discuss video compression techniques later and the concepts also apply to audio compression.

#### (4) Audio Encoding Example

PCM (Pulse Code Modulation) is one technique used with speech, taking 8000 samples per second and each sample's size is 1 byte.

PCM with an audio CD takes 44,100 samples per second with each sample's as 2 bytes.

If there are more samples per second or a large range of quantization values, this means a higher quality of audio while playing back.

#### (5) VoIP Topic 2: Signaling

In traditional telephony, a signaling protocol takes care of how calls are set up and torn down. Signaling protocols are responsible for four major functions,

- User location
- Session establishment: callee can accepting, rejecting, or redirecting a call
- Session negotiation: the endpoints synchronizing with each other on a set of properties for the session
- Call participation management: handling endpoints joining or leaving an existing session

For example, SIP (Session Initiation Protocol) is one example of a signaling protocol used in many VoIP applications.

#### (6) VoIP Topic 3: QoS

QoS metrics for VoIP is a big topic and there are three metrics we used to measure the quality of services,

- end-to-end delay
- jitter
- packet loss

Let's talk about them in the next section.

#### (7) QoS for VoIP 1: End-to-End Delay

In VoIP, the end-to-end delay is composed of the time for,

- encoding audio delay
- data to packets
- network delay (e.g. queueing delay)
- playback delay
- decoding audio delay

Human have different experiences based on the length of end-to-end delay. According to ITU-T Rec.G.114, we have delay time,

-  < 150 ms: unnoticeable by human listeners
-  150 ~ 400 ms: noticeable but acceptable
-  \> 400 ms: unacceptable

#### (8) QoS for VoIP 2: Delay Jitter

Because different voice packets can end up with different amounts of delay, so VoIP has to reconstruct the analog voice stream. The phenomenon that voice packets delay for different lengths of time is called **jitter** (aka. **packet jitter** or **delay jitter**).

With a larger jitter, we can end up more delayed packets and that can lead to a gap in the audio. Because the human ear is pretty intolerant of audio gaps, audio gaps should ideally be kept below 30ms, but depending on the type of voice codec used and other factors, audio gaps between 30 ~ 75ms can be acceptable.

One jitter mitigating technique is to maintain a buffer called **jitter buffer** or **play-out buffer**. The buffer helps smooth out and hide the variation in delay between different received packets by buffering them and playing them out for decoding at a steady rate.

- A longer jitter buffer: reduces the number of packets that are discarded because they were received too late, but that adds to the end-to-end delay.
- A shorter jitter buffer: not add to the end-to-end delay as much, but that can lead to more dropped packets, which reduces the speech quality.

So there has to be a tradeoff in the buffer size.

#### (9) QoS for VoIP 3: Packet Loss

The design of TCP has a problem for VoIP. We have learned that TCP eliminates packet loss by fast retransmission, and the loss packet ends up arriving too late. 

What's more, TCP congestion control algorithms drop the sender’s transmission rate by half every time there’s a dropped packet, so most of the time, VoIP protocols use **UDP**.

So when we talk about packet loss for VoIP, we have a different definition because of the requirement of real-time conversation. For VoIP, a packet is considered lost if,

- it never arrives
- or it arrives after its scheduled playout

To deal with the packet loss of VoIP, there are three major methods,

- FEC (Forward Error Correction)
- Interleaving
- Error concealment

Let's talk about them in the following sections.

#### (10) VoIP Packet Loss Mitigation 1: FEC (Forward Error Concealment) 

The idea of FEC is to transmit redundant data which allows the receiver to replace lost data with the redundant data. This redundant data could be a copy or a lower-quality copy of the original stream. 

However, the more redundant data transmitted, the more bandwidth is consumed. Also, some of these FEC techniques require the receiving end to receive more chunks before playing out the audio, and that increases playout delay.

![](https://i.imgur.com/hxOxr3X.png)

#### (11) VoIP Packet Loss Mitigation 2: Interleaving

The idea of interleaving is to mix chunks of audio together so that if one set of chunks is lost, the
lost chunks aren’t consecutive. The idea is that many smaller audio gaps are preferable to one large audio gap.

This technique has good performance for streaming stored audio but it's limited for VoIP. This is because the receiving side has to wait longer to receive consecutive chunks of audio which increases the latency.

![](https://i.imgur.com/qCC4lQD.png)

#### (12) VoIP Packet Loss Mitigation 3: Error Concealment

Error concealment is basically **guessing** what the lost audio might be. This works becasue generally small audio snippets are very similar to its neighboor. 

The solution is quick and dirty, it means we replace the lost packet with a copy of the previous packetand hopefully that's good enough. Or we can also interpolate an appropriate packet, but there's more computational cost.

### 2. Live And On-Demand Streaming 

#### (1) Streaming Prerequisites 

Nowadays, streaming media over the internet can be more efficient. Various enabling technologies and trends have led to this development of consuming median content over the Internet.

- bandwidth for both the core network and last-mile access links have increased
- video compression technologies have become more efficient
- the development of Digital Rights Management (DRM) culture has encouraged content providers to put their content on the Internet

#### (2) Types of Streaming Content

The types of content that is streamed over the Internet can be divided into two categories,

- Live

The video content is created and delivered to the clients simultaneously. For example, sports events, music concerts etc.

- On-demand

Streaming stored video based on users’ convenience. For example, Netflix, non-live videos on YouTube etc.

In this topic, we will focus mostly on the on-demand streaming.

#### (3) Steps of Video Stream

Let’s begin with a high-level overview of how streaming works,

- Video Creation (high quality)
- Video Compression and Encoding (medium quality)
- Video Secured by DRM hosted over a server
- End-user download video content over the Internet (low quality)
- End-user view the video through user's screen 

#### (4) Image Compression: JPEG File Interchange Format

In this topic we will talk about how to compress images because videos are essentially sequences of digital pictures. An efficient compression can be achieved in two-ways, 

- within an image: similarities among nearby pixel (aka. spatial redundancy)
- across images: similarities among consecutive pictures (aka. temporal redundancy)

To standardize, Joint Photographics Experts Group (JPEG) standard was developed. The main idea behind JPEG is how to represent an image using components that can be further compressed. There are 4 steps in a JPEG format,

- RGB conversion - RGB to [YCbCr](https://en.wikipedia.org/wiki/YCbCr)
    - Y means luminance representing brightness component
    - Cb and Cr are chrominance
- DCT compress (Y Cb Cr) independently
    - Divide the image into `8*8` blocks (sub-image)
    - Apply Discrete Cosine Transformation (DCT) to each sub-images, the result for each image block is an `8*8` table of DCT coefficients. This is done because the human eye is less sensitive to high-frequency coefficients as compared to low-frequency coefficients.
- Compress DCT Coefficients with Quantization table (Q)
    - Compress the matrix of the coefficients using a pre-defined Quantization table (Q)
    - `F_quantized(u, v) = F(u, v) / Q (u, v)`
    - Note that based on the desired image quality, different levels of quantizations can be performed
    - Quantization table is stored in the image header so the image can be later decoded
    - After this step, we will get multiple quantized matrices for each of the 8*8 block in the image
- Lossless Encoding
    - Perform a lossless encoding to store the coefficients. 
    - This finishes the encoding process. This encoded image is then transferred over the network and is decoded at the user-end.

#### (5) Video Compression 1: I-Frame and P-Frame

So far, we looked at how a frame in the video is compressed. But because videos have consecutive frames of temporal redundancy, we can improve the method further more.

So instead of encoding every image as a JPEG, we encode the first (known as **I-frame**) as a JPEG and then encode the difference between two frames. The in-between encoded frame is known as Predicted or **P-frame**.

![](https://i.imgur.com/oPPhFwV.png)

#### (6) Video Compression 2: Group of Pictures (GoP)

There's also a problem when the scene changes and in this case the frame becomes drastically different from the last frame and even if we are using the difference, it is almost like encoding a fresh image. This can lead to loss in image quality.

A typical solution is to insert an I-frame periodically, say after every 15 frames. All the frames between two consecutive I- frames is known as a **Group of Pictures (GoP)**.

![](https://i.imgur.com/26RZm7f.png)

#### (7) Video Compression 3: B-frame

An additional way to improve encoding efficiency is to encode a frame as a function of the past and the future I (or P)-frames. Such a frame is known as a Bi-directional or **B-frame**.

![](https://i.imgur.com/oNKl7rD.png)

#### (8) Video Compression 4: VBR vs CBR

With GoP, the output size of the video is fixed over time and this is known as **Constant BitRate (CBR)** encoding. 

With B-frames, the output size remains the same on an average, but varies here and there based on the underlying scene complexity. This is known as **Variable BitRate (VBR)** encoding.

The image quality is better in VBR as compared to CBR for the same bitrate. However, VBR is more computationally expensive as compared to CBR. In fact, for live streaming, wherein the video compression has to be done real-time, specialized (but expensive) hardware encoders are used by content providers.

In summary,

- CBR: less computational cost
- VBR: higher quality

#### (9) Video Packet Transport Layer Protocol: TCP

Between UDP and TCP, content providers ended up choosing TCP for video delivery as it provides **reliability**. For instance, if an I-frame is lost partially, we may not be able to obtain the RGB matrices correctly. Similarly, if an I-frame was lost, P-frame can not be decoded.

Another benefit from TCP is that it already provides **congestion control** which is required for effectively sharing bandwidth over the Internet.

#### (10) Video Packet Application Layer Protocol: HTTP

With existing HTTP protocol, the server is essentially stateless and the intelligence to download the video will be stored at the clients and this provides several benefits,

- Distributed control: the server is essentially stateless and the intelligence to download the video will be stored at the client
- Providers could use the already existing CDN infrastructure
- Bypassing middleboxes and firewalls easier as they already understood HTTP

![](https://i.imgur.com/T6cMF83.png)


#### (11) Progressive Download

Given all the intelligence for streaming the video would lie at the client-side, there are two ways for a client to fetch a video from a stateless HTTP server,

- HTTP GET: this means to download the whole video as fast as possible
    - waste of network resources because users often leave the video mid-way
    - takes up large memory or storage
- Byte-range requests and playout buffer: instead the client can pace the video download rate by sending byte-range requests. It can also pre-fetches some video ahead and stores it in a playout buffer. Streaming in this manner typically has two states
    - Filling state: video buffer is empty client tries to fill it as soon as possible
    - Steady state: the buffer has become full, the client waits for it to become lower than a threshold. The steady state is characterized by these ON-OFF patterns shown as follows

![](https://i.imgur.com/vROSlPT.png)

#### (12) Bitrate Adaptation

Bitrate adaptation means the video is chunked into segments which are usually of equal duration and each of these segments is then encoded at multiple bitrates and stored at the server. The client knows about the different URLs of each of the video segments through downloading a `manifest` file at the beginning. The client request while requesting for a segment also specifies its **quality**.

For example, once the available bandwidth reduces due to a background download, you can reduce the video quality. This is known as **bitrate adaptation**. 

#### (13) Bitrate Adaptation in Dynamic Streaming over HTTP (DASH)

A video in **DynAmic Streaming over HTTP (DASH)** is divided into chunks and each chunk is encoded into multiple bitrates. Each time the video player needs to download a video chunk, it calls the bitrate adaptation function, say `f`. The function f that takes in some input and outputs the bitrate of the chunk to be downloaded,

```
R(n) = f(input) where R(n) in {R1, R2, ..., Rm}
```

Where `R(n)` denotes the set of available bitrates.

#### (14) Goals of Bitrate Adaptation

A good quality of experience (QoE) of bitrate adaptation algorithm is defined as,

- Low or zero re-buffering
- High video quality
- Low video quality variations
- Low startup latency

#### (15) Bitrate Adaptation Algorithms

In this topic, we will look into the bitrate adaptation algorithm which is the function `f` we have talked about above. 

Here are some signals that can serve as an input to a bitrate adaptation algorithm,

- Network throughput: select a bitrate that is equal or lesser than the available throughput 
- Video buffer: amount of video in the buffer. If the video buffer is full, then the player can possibly afford to download high-quality chunks

So we will have **rate-based adaptatio**n as,

```
R(n) = f(throughput)
```

Or **buffer-based adaptation** as,

```
R(n) = f(buffer_size)
```

#### (16) Rate-Based Adaptation Mechanisms

A simple rate-based adaptation algorithm has the following steps,

- Estimation: estimating the future bandwidth by considering the last few downloaded chunks
- Quantization: select the maximum bitrate that is less than the estimate of the throughput with a **factor**
- Requst: player sends the HTTP GET request for the next chunk once the chunk-bitrate is decided
- Download: the video chunk is downloaded and the download throughput is taken into account in estimating

For this factor we mentioned above, we need it because of the following reasons,

- conservative estimate to avoid re-buffering
- bitrate can exceed the nominal bitrate if VBR
- other additional overheads

#### (17) Throughput-Based Adaptation Mechanisms

The throughput-based adaptation is based on the buffer filling rate and the depletion rate,

- buffer-filling rate

```
buffer-filling rate = network bandwidth C(t) / chunk bitrate R(t)
```

- buffer-depletion rate: 1s of video content gets played in 1s

```
buffer-depletion rate = 1
```

Clearly, for stall-free streaming, the buffer-filling rate should be greater than the buffer-depletion rate. In other words, 

```
C(t) / R(t) > 1 or C(t) > R(t)
```

However, `C(t)` is the future bandwidth and there is no way of knowing it. A good estimate of the future bandwidth is the bandwidth observed in the past. Therefore it uses the previous chunk throughput to decide the bitrate of the next chunk. This is similar to the rate-based adaptation.

#### (18) Bandwidth Estimation Problem with Rate-Based Adaption

- Overestimation

Under the case when the bandwidth changes rapidly, the player takes some time to converge to the right estimate of the bandwidth.

When there's an overestimation on the bandwidth, the video player buffer will deplete and the video will eventually re-buffer. 

If the player uses weighted average then it may even take more time to reflect the drop in the network bandwidth and the player may end up requesting higher bitrate than it should.

- Underestimation

The underestimation of bandwidth happens during the steady state of the DASH clients. Recall we mentioned there's an ON-OFF pattern in the steady state when the buffer is full.

In the OFF period, if the TCP connection reset the congestion window, it does take time for the flows to converge to their fair share. So in our example, it ends up picking a lower bitrate than the observed throughput because of the conservative factor. As the bitrate becomes lower, the chunk size reduces. So this further aggravates the problem.

Note that this problem happens because of the ON-OFF behavior in DASH. While we have seen this problem for DASH and a competing TCP flow, it can also happen in competing DASH players leading to an unfair-allocation of network bandwidth.