#!/bin/bash

echo "Running bert_4Layers_12_head_768_hidden_1024_max_position" >> nv-bert-4L-12H-768Hidden.txt

for seqLen in 256 512 1024
        do

        for batchsize in 1 8 16 32 64 128
                do

                echo -n "Seq Length $seqLen Batchsize $batchsize"
                echo -n "Seq Length $seqLen Batchsize $batchsize" >> nv-bert-4L-12H-768Hidden.txt

                trtexec --onnx=/dockerx/bert_4Layers_12_head_768_hidden_1024_max_position/model.onnx --shapes=input_ids:${batchsize}x${seqLen},attention_mask:${batchsize}x${seqLen},token_type_ids:${batchsize}x${seqLen} --fp16 > temp.txt 2>&1

                throughput=$(grep -oP 'Throughput: \K[0-9]+\.[0-9]+' temp.txt)
                average=$(grep -oP 'mean = \K[0-9]+\.[0-9]+' temp.txt | head -n 1)

                echo "  $average        $throughput"
                echo "  $average        $throughput" >> nv-bert-4L-12H-768Hidden.txt

                rm temp.txt
        done
                echo ""
                echo "" >> nv-bert-4L-12H-768Hidden.txt
done