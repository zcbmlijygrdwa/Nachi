function output = compressToOne(data)

output = data/(max(abs(min(data)),abs(max(data))));

end