//
//  Tutorial1.swift
//  ffmpeg-tutorial-with-swift
//
//  Created by zhangpeng on 9/9/16.
//  Copyright © 2016 zhangpeng. All rights reserved.
//

import Foundation

typealias SwsContext = COpaquePointer

class Tutorial1 {
    func SaveFrame(pFrame:UnsafePointer<AVFrame>, width:Int, height:Int, iFrame:Int) {
        var pFile:UnsafeMutablePointer<FILE> = nil
        let szFilename = "../../frame\(iFrame)"
        // Open file
        pFile = fopen(szFilename, "wb")
        if pFile == nil{
            return
        }
        
        // Write header
        let header = "P6\n\(width) \(height)\n255\n"
        fwrite(header.cStringUsingEncoding(NSUTF8StringEncoding)!, 1, Int(header.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)), pFile)
        
        // Write pixel data
        for i in 0..<height {
            let y = UnsafeBufferPointer(start: pFrame.memory.data.0 + i * Int(pFrame.memory.linesize.0), count: width * 3)
            fwrite(y.baseAddress, 1, width * 3, pFile)
        }
        
        // Close file
        fclose(pFile);
    }
    
    func main(filePath: String)->Int {
        // Initalizing these to NULL prevents segfaults!
        var pFormatCtx:UnsafeMutablePointer<AVFormatContext> = nil
        var videoStream = -1
        var  pCodecCtxOrig:UnsafeMutablePointer<AVCodecContext> = nil
        var  pCodecCtx:UnsafeMutablePointer<AVCodecContext> = nil
        var  pCodec:UnsafeMutablePointer<AVCodec> = nil
        var  pFrame:UnsafeMutablePointer<AVFrame> = nil
        var  pFrameRGB:UnsafeMutablePointer<AVFrame> = nil
        let  packet = UnsafeMutablePointer<AVPacket>.alloc(1)
        //AVPacket          packet;
        let frameFinished = UnsafeMutablePointer<Int32>.alloc(1)
        var               numBytes:Int32 = 0
        var buffer:UnsafeMutablePointer<uint8> = nil
        var sws_ctx:COpaquePointer = nil
        
        if filePath.isEmpty {
            print("Please provide a movie file")
            return -1
        }
        
        // Register all formats and codecs
        av_register_all()
        
        // Open video file
        if avformat_open_input(&pFormatCtx, filePath, nil, nil) != 0 {
            return -1 // Couldn't open file
        }
        
        // Retrieve stream information
        if avformat_find_stream_info(pFormatCtx, nil) < 0 {
            return -1 // Couldn't find stream information
        }
        
        // Dump information about file onto standard error
        av_dump_format(pFormatCtx, 0, filePath, 0)
        
        // Find the first video stream
        videoStream = -1
        for i in 0..<pFormatCtx.memory.nb_streams {
            let s = pFormatCtx.memory.streams[Int(i)]
            if s.memory.codec.memory.codec_type ==  AVMEDIA_TYPE_VIDEO{
                videoStream = Int(i)
                break
            }
        }
        
        if videoStream == -1 {
            return -1 // Didn't find a video stream
        }
        
        // Get a pointer to the codec context for the video stream
        pCodecCtxOrig = pFormatCtx.memory.streams[videoStream].memory.codec
        // Find the decoder for the video stream
        pCodec = avcodec_find_decoder(pCodecCtxOrig.memory.codec_id)
        if pCodec == nil {
            print("Unsupported codec!")
            return -1 // Codec not found
        }
        // Copy context
        pCodecCtx = avcodec_alloc_context3(pCodec)
        if avcodec_copy_context(pCodecCtx, pCodecCtxOrig) != 0 {
            print("Couldn't copy codec context")
            return -1 // Error copying codec context
        }
        
        // Open codec
        if avcodec_open2(pCodecCtx, pCodec, nil) < 0 {
            return -1 // Could not open codec
        }
        
        // Allocate video frame
        pFrame = av_frame_alloc()
        
        // Allocate an AVFrame structure
        pFrameRGB = av_frame_alloc()
        if pFrameRGB == nil {
            return -1
        }
        
        // Determine required buffer size and allocate buffer
        numBytes = avpicture_get_size(PIX_FMT_RGB24, pCodecCtx.memory.width, pCodecCtx.memory.height)
        buffer = UnsafeMutablePointer<uint8>(av_malloc(Int(numBytes)*sizeof(Uint8)))
        
        // Assign appropriate parts of buffer to image planes in pFrameRGB
        // Note that pFrameRGB is an AVFrame, but AVFrame is a superset
        // of AVPicture
        avpicture_fill(UnsafeMutablePointer<AVPicture>(pFrameRGB), buffer, PIX_FMT_RGB24,
                       pCodecCtx.memory.width, pCodecCtx.memory.height)
        
        // initialize SWS context for software scaling
        sws_ctx = sws_getContext(pCodecCtx.memory.width,
                                 pCodecCtx.memory.height,
                                 pCodecCtx.memory.pix_fmt,
                                 pCodecCtx.memory.width,
                                 pCodecCtx.memory.height,
                                 PIX_FMT_RGB24,
                                 SWS_BILINEAR,
                                 nil,
                                 nil,
                                 nil
        );
        
        // Read frames and save first five frames to disk
        var i = 0;
        while av_read_frame(pFormatCtx, packet) >= 0  {
            // Is this a packet from the video stream?
            if packet.memory.stream_index == Int32(videoStream) {
                // Decode video frame
                avcodec_decode_video2(pCodecCtx, pFrame, frameFinished, packet);
                
                // Did we get a video frame?
                if frameFinished.memory == 1 {
                    // Convert the image from its native format to RGB
                    let pFrame_memory_data = [
                        UnsafePointer<UInt8>(pFrame.memory.data.0),
                        UnsafePointer<UInt8>(pFrame.memory.data.1),
                        UnsafePointer<UInt8>(pFrame.memory.data.2),
                        UnsafePointer<UInt8>(pFrame.memory.data.3),
                        UnsafePointer<UInt8>(pFrame.memory.data.4),
                        UnsafePointer<UInt8>(pFrame.memory.data.5),
                        UnsafePointer<UInt8>(pFrame.memory.data.6),
                        UnsafePointer<UInt8>(pFrame.memory.data.7),
                        ]
                    let pFrame_memory_linesize = [
                        pFrame.memory.linesize.0,
                        pFrame.memory.linesize.1,
                        pFrame.memory.linesize.2,
                        pFrame.memory.linesize.3,
                        pFrame.memory.linesize.4,
                        pFrame.memory.linesize.5,
                        pFrame.memory.linesize.6,
                        pFrame.memory.linesize.7
                    ]
                    let pFrameRGB_memory_data = [
                        pFrameRGB.memory.data.0,
                        pFrameRGB.memory.data.1,
                        pFrameRGB.memory.data.2,
                        pFrameRGB.memory.data.3,
                        pFrameRGB.memory.data.4,
                        pFrameRGB.memory.data.5,
                        pFrameRGB.memory.data.6,
                        pFrameRGB.memory.data.7
                    ]
                    let pFrameRGB_memory_linesize = [
                        pFrameRGB.memory.linesize.0,
                        pFrameRGB.memory.linesize.1,
                        pFrameRGB.memory.linesize.2,
                        pFrameRGB.memory.linesize.3,
                        pFrameRGB.memory.linesize.4,
                        pFrameRGB.memory.linesize.5,
                        pFrameRGB.memory.linesize.6,
                        pFrameRGB.memory.linesize.7
                    ]
                    
                    sws_scale(sws_ctx, pFrame_memory_data ,pFrame_memory_linesize, 0, pCodecCtx.memory.height,pFrameRGB_memory_data, pFrameRGB_memory_linesize)
                    
                    // Save the frame to disk
                    if i <= 5 {
                        SaveFrame(pFrameRGB,width:Int(pCodecCtx.memory.width),height:Int(pCodecCtx.memory.height),iFrame:i)
                    }
                    i = i+1
                }
                
                // Free the packet that was allocated by av_read_frame
                av_free_packet(packet)
                if (i > 500) {
                    break
                }
            }
        }
        
        // Free the RGB image
        av_free(buffer)
        av_frame_free(&pFrameRGB)
        
        // Free the YUV frame
        av_frame_free(&pFrame)
        
        // Close the codecs
        avcodec_close(pCodecCtx)
        avcodec_close(pCodecCtxOrig)
        
        // Close the video file
        avformat_close_input(&pFormatCtx)
        
        return 0;
    }
}
