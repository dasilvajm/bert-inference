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

for seqLen in 256 384 512 1024

        do
        for batchsize in 1 8 32 128 256 1024

                do
                python3 e2e_migraphx_bert_example.py --samples 1300 --no_eval --seq_len $seqLen --batch $batchsize --version 2.1 --model /dockerx/$modelPath --fp16 > temp.txt 2>&1

                rate=$(grep "Rate =" temp.txt | awk '{print $3}')
                latency=$(grep "Average Execution time =" temp.txt | awk '{print $5}')

                rate=$(printf "%.2f" "$rate")
                latency=$(printf "%.2f" "$latency")

                echo "$seqLen   $batchsize      $rate   $latency"
                echo "$seqLen   $batchsize      $rate   $latency" >> amd-$model.txt

                rm temp.txt
                done

        echo "" >> amd-$model.txt
        echo ""
done
