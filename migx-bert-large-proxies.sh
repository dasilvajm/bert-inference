#!/bin/bash

rocmversion=$(ls /opt | grep rocm-)

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
echo "$model" >> amd-$model.txt
echo "SLen      BSize   Rate    Latency" >> amd-$model.txt

echo "$model"
echo "SLen      BSize   Rate    Latency"

for seqLen in 256 512 1024

do
        for batchsize in 1 8 16 32 64 128

                do
                /opt/$rocmversion/bin/migraphx-driver perf /dockerx/$modelPath --input-dim @input_ids $batchsize $seqLen @attention_mask $batchsize $seqLen @token_type_ids $batchsize $seqLen --fill1 input_ids attention_mask token_type_ids --batch $batchsize --fp16 > temp.txt 2>&1

                file_content=$(<temp.txt)
                throughput=$(echo "$file_content" | grep -oP '(?<=Rate: )\d+\.\d+(?= inferences/sec)')
                latency=$(echo "$file_content" | grep -oP '(?<=Total time: )\d+\.\d+' | sed 's/ms//')

                throughput=$(printf "%.2f" "$throughput")
                latency=$(printf "%.2f" "$latency")

                echo "$seqLen   $batchsize      $throughput     $latency"
                echo "$seqLen   $batchsize      $throughput     $latency" >> amd-$model.txt

                rm temp.txt
                done

        echo "" >> amd-$model.txt
        echo ""
done
