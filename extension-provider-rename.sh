for n in provider_path provider_name extension_function_name extension_clear_key extension_function_suffix extension; do
  nn=$(printf '%s' $n | sed -e 's/extension/provider/g')
  printf '%s -> %s\n' $n $nn
  sed -i "s/$n/$nn/g" $(search -l $n)
done
