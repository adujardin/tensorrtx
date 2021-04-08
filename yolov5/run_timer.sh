
set_network_size() {
    width=$1
    height=$2
    sed -i '/static constexpr int INPUT_W =/c\static constexpr int INPUT_W = '${width}';' yololayer.h
    sed -i '/static constexpr int INPUT_H =/c\static constexpr int INPUT_H = '${height}';' yololayer.h
}

yolov5_variants=("s" "m" "l" "x")
image_sizes=("320" "384" "416" "512" "608" "640")

# Compile for the first time
mkdir build; cd build; cmake ..; make -j; cd ..

for variant in "${yolov5_variants[@]}"; do
    # Get WTS file
    wget "https://stereolabs.sfo2.cdn.digitaloceanspaces.com/ai/model/others/yolov5${variant}_v4.0.wts"
    for size in "${image_sizes[@]}"; do
        # Set size
        set_network_size ${size} ${size}
        # Compile
        cd build; make; cd ..
        # Generate engine
        engine_name="./yolov5${variant}_${size}_fp16_v4.0.engine"
        build/yolov5 -s "./yolov5${variant}_v4.0.wts" ${engine_name} ${variant}
        # Run engine
        build/yolov5 -d ${engine_name} ./samples
    done 
done