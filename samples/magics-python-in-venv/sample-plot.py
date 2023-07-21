import os
import tempfile

import requests

from Magics import macro as magics


fd, grib = tempfile.mkstemp()
try:
    with requests.get(
        "http://download.ecmwf.int/test-data/magics/2m_temperature.grib", stream=True
    ) as r:
        r.raise_for_status()
        for chunk in r.iter_content():
            os.write(fd, chunk)
finally:
    os.close(fd)

output = magics.output(
    output_formats=["png"], output_name_first_page_number="off", output_name="magics"
)
data = magics.mgrib(grib_input_file_name=grib)
contour = magics.mcont(
    contour_automatic_setting="ecmwf",
)
coast = magics.mcoast()
magics.plot(output, data, contour, coast)
