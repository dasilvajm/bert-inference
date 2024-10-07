#!/bin/bash

echo "Please choose one of the following options:"
echo "(1) bert_24Layers_16_head_1024_hidden"
echo "(2) bert_24Layers_12_head_768_hidden"
echo "(3) bert_12Layers_16_head_1024_hidden"
echo "(4) bert_12Layers_12_head_768_hidden"
echo "(5) bert_6Layers_16_head_1024_hidden"
echo "(6) bert_6Layers_12_head_768_hidden"
echo "(7) bert_4Layers_16_head_1024_hidden"
echo "(8) bert_4Layers_12_head_768_hidden"
echo ""
read -p "Enter your choice (1-8): " choice

case $choice in
    1) model="bert_24Layers_16_head_1024_hidden";;
    2) model="bert_24Layers_12_head_768_hidden";;
    3) model="bert_12Layers_16_head_1024_hidden";;
    4) model="bert_12Layers_12_head_768_hidden";;
    5) model="bert_6Layers_16_head_1024_hidden";;
    6) model="bert_6Layers_12_head_768_hidden";;
    7) model="bert_4Layers_16_head_1024_hidden";;
    8) model="bert_4Layers_12_head_768_hidden";;
    *) echo "Invalid choice"; exit 1;;
esac

modelPath="${model}_1024_max_position/model.onnx"

echo ""
echo "$model" >> nv-$model.txt
echo "SLen      BSize   QPS    Latency" >> nv-$model.txt

echo "$model"
echo "SLen      BSize   QPS    Latency"

for seqLen in 256 512 1024
	do
        for batchsize in 1 8 16 32 64 128
        	do
                trtexec --onnx=/dockerx/$modelPath --shapes=input_ids:${batchsize}x${seqLen},attention_mask:${batchsize}x${seqLen},token_type_ids:${batchsize}x${seqLen} --fp16 > temp.txt 2>&1

                throughput=$(grep -oP 'Throughput: \K[0-9]+\.[0-9]+' temp.txt)
                average=$(grep -oP 'mean = \K[0-9]+\.[0-9]+' temp.txt | head -n 1)

		throughput=$(printf "%.2f" "$throughput")
		average=$(printf "%.2f" "$average")

		echo "$seqLen   $batchsize      $throughput     $average"
		echo "$seqLen   $batchsize      $throughput     $average" >> nv-$model.txt
                
                rm temp.txt
        done
                echo ""
                echo "" >> nv-$model.txt
done
