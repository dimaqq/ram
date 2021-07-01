import json
import pathlib
import sys

import avro.io
import avro.datafile

if __name__ == "__main__":
    if not sys.argv[1:]:
        raise Exception("""
            Usage: %s filename.avro
        """ % sys.argv[0])
    path = pathlib.Path(sys.argv[1])
    data = avro.datafile.DataFileReader(path.open("rb"), avro.io.DatumReader())
    # escape double quotes for use in terraform
    print(json.dumps(data.schema))
