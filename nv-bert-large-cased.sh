#!/bin/bash

echo "Running bert-24L-16H-1024Hidden" >> nv-bert-24L-16H-1024Hidden.txt

for seqLen in 256 512 1024
        do

        for batchsize in 1 8 16 32 64 128
                do

                echo -n "Seq Length $seqLen Batchsize $batchsize"
                echo -n "Seq Length $seqLen Batchsize $batchsize" >> nv-bert-24L-16H-1024Hidden.txt

                trtexec --onnx=/dockerx/bert_24Layers_16_head_1024_hidden_1024_max_position/model.onnx --shapes=input_ids:${batchsize}x${seqLen},attention_mask:${batchsize}x${seqLen},token_type_ids:${batchsize}x${seqLen} --fp16 > temp.txt 2>&1

                throughput=$(grep -oP 'Throughput: \K[0-9]+\.[0-9]+' temp.txt)
                average=$(grep -oP 'mean = \K[0-9]+\.[0-9]+' temp.txt | head -n 1)

                echo "  $average        $throughput"
                echo "  $average        $throughput" >> nv-bert-24L-16H-1024Hidden.txt

                rm temp.txt
        done
                echo ""
                echo "" >> nv-bert-24L-16H-1024Hidden.txt
done
