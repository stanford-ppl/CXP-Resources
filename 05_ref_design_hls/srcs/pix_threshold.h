#ifndef PIX_THRESHOLD_H_
#define PIX_THRESHOLD_H_

#include "CustomLogic.h"
#include <hls_stream.h>
using namespace hls;

void pix_threshold(stream<video_if_t> &VideoIn,stream<video_if_t> &VideoOut,
				 Metadata_t *MetaIn,Metadata_t *MetaOut,pixMono8 threshold_value);

#endif
