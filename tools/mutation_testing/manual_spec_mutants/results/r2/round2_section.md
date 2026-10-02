## Round 2 (agent/manual-spec-mutations-r2)

faults: 317; proofs: {'SURVIVED': 71, 'KILLED': 221, 'UNJUDGED': 25}

| fault | type | file | fault | A | killed by | B |
|---|---|---|---|---|---|---|
| r2-a01-bytelist-append-grow/01 | bytelist_256 | types/bytelist_256_def_generated.bend | room is made for n elements, not n + 1 (storage can be one word short, the write lands outside the array) | SURVIVED |  |  |
| r2-a01-bytelist-append-grow/02 | bytelist_256 | types/bytelist_256_def_generated.bend | the length is resized to n (the appended element is not counted) | SURVIVED |  |  |
| r2-a01-bytelist-append-guard/01 | bytelist_256 | types/bytelist_256_def_generated.bend | the append guard is n <= 256 (a 257th element is accepted) | SURVIVED |  |  |
| r2-a01-bytelist-append-guard/02 | bytelist_256 | types/bytelist_256_def_generated.bend | the append guard is n < 255 (the 256th element is refused) | SURVIVED |  |  |
| r2-a01-bytelist-append-guard/03 | bytelist_256 | types/bytelist_256_def_generated.bend | the append value range is v <= 256 (the value 256 is stored and spills into the next byte) | SURVIVED |  |  |
| r2-a01-bytelist-append-guard/04 | bytelist_256 | types/bytelist_256_def_generated.bend | the two append conditions are or-ed | SURVIVED |  |  |
| r2-a01-bytelist-append-guard/05 | bytelist_256 | types/bytelist_256_def_generated.bend | the value is written at index n + 1 (a hole at n, the length grows by one) | SURVIVED |  |  |
| r2-a01-bytelist-getter/01 | bytelist_256 | types/bytelist_256_def_generated.bend | the getter bound is i <= n (index n reads the zero padding and answers Some(0)) | SURVIVED |  |  |
| r2-a01-bytelist-setter/01 | bytelist_256 | types/bytelist_256_def_generated.bend | the setter bound is i <= n (an element one past the end is written, the length unchanged) | SURVIVED |  |  |
| r2-a01-bytelist-setter/02 | bytelist_256 | types/bytelist_256_def_generated.bend | the setter does not check the value range (v up to 2^32 - 1 is merged into the word) | SURVIVED |  |  |
| r2-a02-large-limit-append/01 | Fulu_list_uint8_1099511627776 | types/Fulu_list_uint8_1099511627776_def_generated.bend | the guard is n <= 4294967295 (always true: the append at n = 2^32 - 1 wraps the count to 0) | KILLED | l1099511627776_u8_api_witness_generated.bend: l1099511627776_u8_api_append_flag |  |
| r2-a02-large-limit-append/02 | Fulu_list_uint8_1099511627776 | types/Fulu_list_uint8_1099511627776_def_generated.bend | the guard is n < 4294967294 (one element less) | KILLED | l1099511627776_u8_api_witness_generated.bend: l1099511627776_u8_api_append_flag |  |
| r2-a02-large-limit-append/03 | Fulu_list_uint8_1099511627776 | types/Fulu_list_uint8_1099511627776_def_generated.bend | the guard is the wrapped sum (n + 1) <= 4294967295 | KILLED | l1099511627776_u8_api_witness_generated.bend: l1099511627776_u8_api_append_flag |  |
| r2-a02-large-limit-append/04 | proglist_uint8 | types/proglist_uint8_def_generated.bend | the guard is n <= 4294967295 (always true) | KILLED | crash_fix_laws_generated.bend: pl_u8_append_max_refused |  |
| r2-a02-large-limit-append/05 | progbitlist | types/progbitlist_def_generated.bend | the guard is n <= 4294967295 (always true) | KILLED | crash_fix_laws_generated.bend: pbits_append_max_refused |  |
| r2-a03-bits-append/01 | bitlist_9 | types/bitlist_9_def_generated.bend | the append guard is n <= 9 (a tenth bit is accepted) | SURVIVED |  |  |
| r2-a03-bits-append/02 | bitlist_9 | types/bitlist_9_def_generated.bend | the append guard is n < 8 (the ninth bit is refused) | SURVIVED |  |  |
| r2-a03-bits-append/03 | bitlist_9 | types/bitlist_9_def_generated.bend | the setter bound is i <= n (the bit past the end is set, length unchanged) | SURVIVED |  |  |
| r2-a03-bits-append/04 | bitlist_9 | src/obj.bend | the new bit is stored at index k + 1 | SURVIVED |  |  |
| r2-a03-bits-append/05 | bitlist_9 | src/obj.bend | the length stays k after the push | SURVIVED |  |  |
| r2-a03-bits-append/06 | bitlist_9 | src/obj.bend | bit_merge is inverted (True clears, False sets) | KILLED | u32bits.bend: bit_merge_other |  |
| r2-a04-element-array-append/01 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the append guard is n <= 16 (a 17th element is accepted) | KILLED | cspec_l16_WithdrawalRequest.bend: app_eq |  |
| r2-a04-element-array-append/02 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the room test is n <= cap (an append at n = cap writes one past the storage) | KILLED | cached_l16_WithdrawalRequest.bend: grow_eq |  |
| r2-a04-element-array-append/03 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the copy loop moves n - 1 elements (the last element is lost) | KILLED | cached_l16_WithdrawalRequest.bend: room_pick_eq |  |
| r2-a04-element-array-append/04 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the new storage is sized for n elements (not n + 1) | KILLED | cached_l16_WithdrawalRequest.bend: room_pick_eq |  |
| r2-a04-element-array-append/05 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the count becomes n + 2 | KILLED | collections_0.bend: l16_WithdrawalRequest_append_length |  |
| r2-a04-element-array-append/06 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the setter bound is i <= n | KILLED | cspec_l16_WithdrawalRequest.bend: set_eq |  |
| r2-a04-element-array-append/07 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the getter bound is i <= n (index n answers the default element) | KILLED | l16_WithdrawalRequest_api_witness_generated.bend: l16_WithdrawalRequest_api_get_outside |  |
| r2-a05-cached-append/01 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the cached append guard is n <= 16 | KILLED | cached_l16_WithdrawalRequest.bend: capp_eq |  |
| r2-a05-cached-append/02 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the fit test is n <= 2^d (the leaf 2^d is stored in a tree of 2^d leaves) | KILLED | cached_l16_WithdrawalRequest.bend: capp_eq |  |
| r2-a05-cached-append/03 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the deepened cache keeps depth d | KILLED | cached_l16_WithdrawalRequest.bend: grow_eq |  |
| r2-a05-cached-append/04 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the dirty range after deepening is 0 .. 2^d - 1 (the new right half is never hashed) | KILLED | cached_l16_WithdrawalRequest.bend: grow_eq |  |
| r2-a05-cached-append/05 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | only the lower dirty bound is updated (hi keeps its value) | KILLED | cached_l16_WithdrawalRequest.bend: set_state |  |
| r2-a05-cached-append/06 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the cached set bound is i <= n | KILLED | cached_l16_WithdrawalRequest.bend: cset_eq |  |
| r2-a06-cells/01 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the setter takes a cell of at most 2048 bytes (a shorter cell is written and the tail of the old cell is kept) | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_set_flag |  |
| r2-a06-cells/02 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the setter takes a cell of at least 2048 bytes (a longer cell overruns the next one) | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_set_flag |  |
| r2-a06-cells/03 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the setter bound is i <= n (writes the cell after the last) | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_set_flag |  |
| r2-a06-cells/04 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the append guard is n + 1 < 4096 (4095 cells at most) | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_append_flag |  |
| r2-a06-cells/05 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the append guard is n + 1 <= 4097 (4097 cells) | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_append_flag |  |
| r2-a06-cells/06 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the append length check is dropped | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_append_flag |  |
| r2-a06-cells/07 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the append length check is vn <= 2048 | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_append_flag |  |
| r2-a06-cells/08 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the count divides by 2047 | SURVIVED |  |  |
| r2-a06-cells/09 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the getter slices 2047 bytes | UNJUDGED |  |  |
| r2-a06-cells/10 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the getter starts at byte 2048 (i + 1) | UNJUDGED |  |  |
| r2-a06-cells/11 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the room is made for n cells (the write lands outside the storage) | SURVIVED |  |  |
| r2-a07-words-blit/01 | FuluDataColumnSidecar | src/obj.bend | the empty test is n <= 0 (same as n = 0 on an unsigned count) | SURVIVED |  |  |
| r2-a07-words-blit/02 | FuluDataColumnSidecar | src/obj.bend | the empty guard is removed (the loop count n/4 - 1 wraps to 2^32 - 1 for n = 0) | SURVIVED |  |  |
| r2-a07-words-blit/03 | FuluDataColumnSidecar | src/obj.bend | the word count drops the rounding (n >> 2 words, a final partial word is not copied) | SURVIVED |  |  |
| r2-a07-words-blit/04 | FuluDataColumnSidecar | src/obj.bend | the destination word base is p (not p >> 2) | SURVIVED |  |  |
| r2-a07-words-blit/05 | FuluDataColumnSidecar | src/obj.bend | the destination word is stored at base + j + 1 (one word late) | KILLED | cell_rw.bend: blc0 |  |
| r2-a07-words-blit/06 | FuluDataColumnSidecar | src/obj.bend | the source index advances by 2 (every second word) | KILLED | cell_rw.bend: blc_step |  |
| r2-a07-words-blit/07 | FuluDataColumnSidecar | src/obj.bend | the returned source length is n + 1 | SURVIVED |  |  |
| r2-a08-words-fit/01 | bytelist_256 | src/obj.bend | the room test is `want-chunks <= cap` replaced by `< cap` (grows one append early, equivalent in result) | KILLED | words_rw.bend: fit_roomy |  |
| r2-a08-words-fit/02 | bytelist_256 | src/obj.bend | the room test is `<= cap + 8` (a full chunk of slack is assumed: storage can be too small by up to eight words) | KILLED | words_rw.bend: fit_roomy |  |
| r2-a08-words-fit/03 | bytelist_256 | src/obj.bend | the grow copies ceil(n/4) - 1 words (the last word is lost) | KILLED | words_rw.bend: fit_grow |  |
| r2-a08-words-fit/04 | bytelist_256 | src/obj.bend | the grown storage is sized for n bytes (not want) | KILLED | words_rw.bend: fit_grow |  |
| r2-b01-buffer-reads/01 | VarTestStruct | src/buffer.bend | byte 1 is selected with a 16-bit shift | KILLED | g__sub_boolean_generated.bend: sel1 |  |
| r2-b01-buffer-reads/02 | VarTestStruct | src/buffer.bend | byte 3 is selected with a 16-bit shift | KILLED | g__sub_boolean_generated.bend: sel3 |  |
| r2-b01-buffer-reads/03 | VarTestStruct | src/buffer.bend | byte 0 keeps seven bits (mask 127) | KILLED | g__sub_boolean_generated.bend: sel0 |  |
| r2-b01-buffer-reads/04 | VarTestStruct | src/buffer.bend | the in-word index is i mod 2 | KILLED | reads.bend: byte_any |  |
| r2-b01-buffer-reads/05 | VarTestStruct | src/buffer.bend | the word index is i / 8 | KILLED | reads.bend: byte_any |  |
| r2-b02-unaligned-read/01 | VarTestStruct | src/buffer.bend | the high part is shifted by 16 | KILLED | vua_bits.bend: joinC1 |  |
| r2-b02-unaligned-read/02 | VarTestStruct | src/buffer.bend | the high part is shifted by 16 | KILLED | vua_bits.bend: joinC3 |  |
| r2-b02-unaligned-read/03 | VarTestStruct | src/buffer.bend | the low part is shifted by 16 | KILLED | vua_bits.bend: joinC3 |  |
| r2-b02-unaligned-read/04 | VarTestStruct | src/buffer.bend | the high part is two words on | KILLED | reads.bend: read32_case |  |
| r2-b02-unaligned-read/05 | VarTestStruct | src/buffer.bend | an offset is taken as aligned iff i mod 2 = 0 (offsets 2 mod 4 read the whole word) | KILLED | reads.bend: read32_any |  |
| r2-b02-unaligned-read/06 | ComplexTestStruct | src/buffer.bend | the high word is read at i + 8 | KILLED | var_fix_types.bend: rd_u64 |  |
| r2-b02-unaligned-read/07 | ComplexTestStruct | src/buffer.bend | the pair is (high, low) | KILLED | var_fix_types.bend: rd_u64 |  |
| r2-b03-byte-swap/01 | FuluCheckpoint | src/buffer.bend | byte 1 goes to bits 8..15 | KILLED | root_leaf.bend: swap0 |  |
| r2-b03-byte-swap/02 | FuluCheckpoint | src/buffer.bend | the mask of byte 0 is dropped | KILLED | root_leaf.bend: swap0 |  |
| r2-b03-byte-swap/03 | FuluCheckpoint | src/buffer.bend | the top byte is shifted by 16 | KILLED | root_leaf.bend: swap2 |  |
| r2-b04-storage-depth/01 | VarTestStruct | src/buffer.bend | the threshold of the 2-bit step is 3 (w = 3 words gets depth 1: an array of two words) | KILLED | vdepth.bend: u2 |  |
| r2-b04-storage-depth/02 | VarTestStruct | src/buffer.bend | the threshold of the 4-bit step is 5 | KILLED | vdepth.bend: u4 |  |
| r2-b04-storage-depth/03 | ComplexTestStruct | src/buffer.bend | the threshold of the 8-bit step is 17 | KILLED | vdepth.bend: u8 |  |
| r2-b04-storage-depth/04 | FuluDataColumnSidecar | src/buffer.bend | the threshold of the 16-bit step is 257 | KILLED | vdepth.bend: u16 |  |
| r2-b04-storage-depth/05 | FuluDataColumnSidecar | src/buffer.bend | the two-level threshold is 65537 | KILLED | vdepth.bend: unz |  |
| r2-b04-storage-depth/06 | bytelist_256 | src/buffer.bend | the threshold of the 2-bit step is 3 | KILLED | vdepth.bend: st2c |  |
| r2-b04-storage-depth/07 | bytelist_256 | src/buffer.bend | the threshold of the 4-bit step is 5 | KILLED | vdepth.bend: st4c |  |
| r2-b04-storage-depth/08 | bytelist_256 | src/buffer.bend | the last bit adds nothing (m = 1 is not rounded up) | KILLED | vdepth.bend: st0c |  |
| r2-b04-storage-depth/09 | FuluBytes48 | src/buffer.bend | 5 words get depth 2 (an array of four words for five) | SURVIVED |  |  |
| r2-b04-storage-depth/10 | FuluBytes48 | src/buffer.bend | 9 words get depth 3 | SURVIVED |  |  |
| r2-b04-storage-depth/11 | FuluBytes48 | src/buffer.bend | the loop halves with floor ((need) >> 1 instead of (need + 1) >> 1) | SURVIVED |  |  |
| r2-d01-decode-checked/01 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the window test is size < n (a window that is exactly the buffer is refused) | KILLED | crash_fix_laws_generated.bend: decode_checked_inside_accepted |  |
| r2-d01-decode-checked/02 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the window-inside-buffer test is dropped (a size past the buffer is decoded: out-of-bounds reads) | KILLED | crash_fix_laws_generated.bend: decode_checked_empty_buffer_refused |  |
| r2-d01-decode-checked/03 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the 2^31 bound is dropped (any size up to the buffer length is decoded) | SURVIVED |  |  |
| r2-d01-decode-checked/04 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the 2^31 bound is size <= 2^31 (the 2 GiB window is accepted) | SURVIVED |  |  |
| r2-d01-decode-checked/05 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the 2^31 bound is size < 2^32 - 1 (everything below the U32 maximum is accepted) | SURVIVED |  |  |
| r2-d01-decode-checked/06 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the 2^31 bound is size < 2^31 - 1 (the window 2^31 - 1 is refused) | SURVIVED |  |  |
| r2-d01-decode-checked/07 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the two conditions are or-ed (either one accepts) | KILLED | crash_fix_laws_generated.bend: decode_checked_empty_buffer_refused |  |
| r2-d01-decode-checked/08 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the buffer test is n <= size (reversed comparison: only windows at least the buffer length pass) | KILLED | crash_fix_laws_generated.bend: decode_checked_empty_buffer_refused |  |
| r2-d01-decode-checked/09 | VarTestStruct | types/VarTestStruct_decode_ssz_generated.bend | the window-inside-buffer test is dropped | SURVIVED |  |  |
| r2-d01-decode-checked/10 | VarTestStruct | types/VarTestStruct_decode_ssz_generated.bend | the 2^31 bound is size <= 2^31 | SURVIVED |  |  |
| r2-d01-decode-checked/11 | VarTestStruct | types/VarTestStruct_decode_ssz_generated.bend | the two conditions are or-ed | SURVIVED |  |  |
| r2-d01-decode-checked/12 | bitlist_9 | types/bitlist_9_decode_ssz_generated.bend | the 2^31 bound is dropped | SURVIVED |  |  |
| r2-d01-decode-checked/13 | bitlist_9 | types/bitlist_9_decode_ssz_generated.bend | the window-inside-buffer test is dropped | SURVIVED |  |  |
| r2-d01-decode-checked/14 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the checked entry passes the window size as the buffer size (the comparison is vacuous) | KILLED | crash_fix_laws_generated.bend: decode_checked_empty_buffer_refused |  |
| r2-h01-mix-in-length/01 | VarTestStruct | src/obj.bend | the length is put in the second word | KILLED | list_obj.bend: mix_bytes |  |
| r2-h01-mix-in-length/02 | VarTestStruct | src/obj.bend | the length mixed in is n + 1 | KILLED | list_obj.bend: mix_bytes |  |
| r2-h01-mix-in-length/03 | bitlist_9 | src/obj.bend | the byte count ceil(k/8) is mixed in | KILLED | pbits_obj.bend: bst |  |
| r2-h01-mix-in-length/04 | bitlist_9 | src/obj.bend | the count includes the delimiter bit (k + 1) | KILLED | pbits_obj.bend: bst |  |
| r2-h02-chunk-count/01 | bytelist_256 | src/obj.bend | the chunk-presence flag is 0 <= chunks (always true) | KILLED | pv_obj.bend: bv_state |  |
| r2-h02-chunk-count/02 | bytelist_256 | src/obj.bend | the tree width is 2^depth * 2 | KILLED | pv_obj.bend: bv_state |  |
| r2-h03-subtree-split/01 | bytelist_256 | src/obj.bend | the right half starts at s + w | KILLED | mtree_run.bend: mt_words |  |
| r2-h03-subtree-split/02 | bytelist_256 | src/obj.bend | the right half is inside iff s + w/2 <= n | KILLED | mtree_run.bend: mt_words |  |
| r2-h03-subtree-split/03 | FuluDataColumnSidecar | src/obj.bend | the zero subtree of an element's empty right half uses Z(d - 1) | KILLED | elems_obj.bend: ct_words |  |
| r2-h03-subtree-split/04 | FuluDataColumnSidecar | src/obj.bend | the element tree's right half starts at s + w | KILLED | elems_obj.bend: ct_words |  |
| r2-h03-subtree-split/05 | bytelist_256 | src/obj.bend | the join hashes right // left | KILLED | mtree_run.bend: mt_words |  |
| r2-h03-subtree-split/06 | bytelist_256 | src/obj.bend | the seventh word is read from b + 6 (repeats a word) | KILLED | mtree_run.bend: chunk_read |  |
| r2-h03-subtree-split/07 | bytelist_256 | src/obj.bend | the last word of a chunk is not byte-swapped | KILLED | mtree_run.bend: chunk_read |  |
| r2-h04-element-chunks/01 | FuluDataColumnSidecar | src/obj.bend | word 8c+4 is taken inside the element when j + 4 <= ew (reads the next element's first word) | KILLED | elems_obj.bend: echunk_read |  |
| r2-h04-element-chunks/02 | FuluDataColumnSidecar | src/obj.bend | the first word of the chunk is read unconditionally | KILLED | elems_obj.bend: echunk_read |  |
| r2-h04-element-chunks/03 | FuluDataColumnSidecar | src/obj.bend | the chunk count of an element is floor(ew / 8) | KILLED | elems48.bend: ev_st |  |
| r2-h04-element-chunks/04 | FuluDataColumnSidecar | src/obj.bend | element i starts at word i * (ew + 1) | KILLED | elems_obj.bend: mt_elems |  |
| r2-h04-element-chunks/05 | FuluDataColumnSidecar | src/obj.bend | the element count divides by 4 ew + 4 | KILLED | cells.bend: ev_st |  |
| r2-h05-scalar-chunks/01 | FuluBeaconBlockHeader | src/obj.bend | true is chunk 0x00000001 in the first word (big-endian word, wrong byte) | KILLED | root_leaf.bend: bool_root |  |
| r2-h05-scalar-chunks/02 | FuluValidator | src/obj.bend | false is the all-ones chunk word | KILLED | root_leaf.bend: bool_root |  |
| r2-h05-scalar-chunks/03 | FuluCheckpoint | src/obj.bend | the value is not byte-swapped | KILLED | leaf_small.bend: u32_root |  |
| r2-h05-scalar-chunks/04 | FuluCheckpoint | src/obj.bend | the two words are swapped (high word first) | KILLED | root_leaf.bend: u64_root |  |
| r2-h05-scalar-chunks/05 | FuluCheckpoint | src/obj.bend | the high word is dropped | KILLED | root_leaf.bend: u64_root |  |
| r2-h06-bit-roots/01 | bitlist_513 | src/obj.bend | the chunked bytes are k (bit count) instead of ceil(k / 8) | KILLED | pbits_obj.bend: bst |  |
| r2-h06-bit-roots/02 | progbitlist | src/obj.bend | the byte count is used as the mixed length | KILLED | pbits_obj.bend: pst |  |
| r2-h06-bit-roots/03 | bitlist_513 | src/obj.bend | the byte count is floor(k / 8) | KILLED | vbitenc.bend: E3 |  |
| r2-h07-progressive/01 | ProgressiveTestStruct | src/obj.bend | the remainder is inside when s + 2^dep <= n (an empty remainder is hashed as a node) | KILLED | prog_root.bend: pt_run |  |
| r2-h07-progressive/02 | ProgressiveTestStruct | src/obj.bend | the segment's tree has width 2^(dep+1) | KILLED | prog_root.bend: pt_run |  |
| r2-h07-progressive/03 | ProgressiveTestStruct | src/obj.bend | the fuel is the chunk count (designed equivalent: log4 n steps suffice) | KILLED | pbits_obj.bend: pst |  |
| r2-h07-progressive/04 | ProgressiveTestStruct | src/obj.bend | the emptiness flag is 0 <= n (an empty list is hashed as a node) | KILLED | pbits_obj.bend: pst |  |
| r2-h08-zero-hashes/01 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(6) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/02 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(18) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/03 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(20) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/04 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(40) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/05 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(41) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/06 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(63) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/07 | FuluExecutionRequests | src/digest.bend | Z(0) is not zero (first word 1) | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/08 | FuluExecutionRequests | src/digest.bend | the table ends one level early: Z(63) answers the zero chunk | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/09 | FuluExecutionRequests | src/digest.bend | the node hashes right // left | KILLED | FuluExecutionRequests_hashtreeroot_proof_generated.bend: hash_pair_packed |  |
| r2-h08-zero-hashes/10 | FuluExecutionRequests | src/digest.bend | the message length is hl - 1 (63 bytes) | KILLED | FuluExecutionRequests_hashtreeroot_proof_generated.bend: hash_pair_packed |  |
| r2-h09-streaming-merkleizer/01 | FuluExecutionRequests | src/merkle_fast.bend | the empty tree answers Z(0) | SURVIVED |  |  |
| r2-h09-streaming-merkleizer/02 | FuluExecutionRequests | src/merkle_fast.bend | the depth rounds down: (limit + 1) is replaced by limit | SURVIVED |  |  |
| r2-h09-streaming-merkleizer/03 | FuluExecutionRequests | src/merkle_fast.bend | climb hashes the stack entry on the right | SURVIVED |  |  |
| r2-h09-streaming-merkleizer/04 | FuluExecutionRequests | src/merkle_fast.bend | the start is 4^k / 3 | SURVIVED |  |  |
| r2-h09-streaming-merkleizer/05 | FuluExecutionRequests | src/merkle_fast.bend | the table fill hashes Z(k) with the zero chunk | SURVIVED |  |  |
| r2-h09-streaming-merkleizer/06 | FuluExecutionRequests | src/merkle_fast.bend | the table is never filled | SURVIVED |  |  |
| r2-h10-reference-library/01 | FuluExecutionRequests | src/merkle.bend | zero_hash(d + 1) hashes the child with the zero chunk | KILLED | cached_tree.bend: built_lookup |  |
| r2-h10-reference-library/02 | FuluExecutionRequests | src/merkle.bend | the right operand's length is not checked | KILLED | merkle.bend: hash_pair_correct |  |
| r2-h10-reference-library/03 | FuluExecutionRequests | src/mixing.bend | the selector bound is dropped | KILLED | mixing.bend: mix_in_selector_correct |  |
| r2-h10-reference-library/04 | FuluExecutionRequests | src/mixing.bend | the selector chunk is padded on the left (31 zero bytes then the selector would be big-endian; here the pad length is 31) | KILLED | mixing.bend: mix_in_selector_correct |  |
| r2-h10-reference-library/05 | FuluExecutionRequests | src/mixing.bend | the root and the root length chunk are mixed in the other order | KILLED | mixing.bend: mix_in_length_correct |  |
| r2-h10-reference-library/06 | ProgressiveTestStruct | src/progressive.bend | the depth grows by 1 (2x) instead of 2 (4x) | KILLED | cached_tree.bend: progressive_go_correct |  |
| r2-h10-reference-library/07 | ProgressiveTestStruct | src/progressive.bend | the segment is the left operand | KILLED | cached_tree.bend: progressive_join |  |
| r2-h10-reference-library/08 | ProgressiveTestStruct | src/progressive.bend | the fuel is one less than the chunk count | KILLED | cached_tree.bend: progressive_gate_correct |  |
| r2-h10-reference-library/09 | bytelist_256 | src/packing.bend | a chunk completes after 30 bytes (room starts at 30) | KILLED | packing.bend: checked_correct |  |
| r2-h10-reference-library/10 | bytelist_256 | src/packing.bend | after a full chunk the room is 30 | KILLED | packing.bend: scan_correct |  |
| r2-h10-reference-library/11 | bytelist_256 | src/packing.bend | the pad is one byte short | KILLED | packing.bend: finish_correct |  |
| r2-h10-reference-library/12 | ProgressiveTestStruct | src/tree.bend | the missing subtree of depth 1+p is zero_hash(p) | KILLED | cached_tree.bend: consume_correct |  |
| r2-h10-reference-library/13 | ProgressiveTestStruct | src/tree.bend | residual chunks are ignored | KILLED | tree.bend: finish_drop |  |
| r2-h10-reference-library/14 | bitlist_9 | src/bit_root.bend | the limit is (n + 256) / 256 | KILLED | bit_chunk_count.bend: count_bits |  |
| r2-h10-reference-library/15 | bitlist_9 | src/bit_root.bend | the bit count is encoded in 8 bytes | KILLED | bit_list_root.bend: list_gate_correct |  |
| r2-h10-reference-library/16 | bitlist_9 | src/root.bend | the count is encoded in 8 bytes | KILLED | root_scope.bend: length_mix_scope |  |
| r2-h10-reference-library/17 | FuluExecutionRequests | src/root.bend | the basic-size limit rounds down | KILLED | root_total_steps.bend: packed_sound |  |
| r2-h10-reference-library/18 | ProgressiveTestStruct | src/root.bend | an inactive field contributes nothing (the slot is skipped) | KILLED | root_total_steps.bend: placed_chunks |  |
| r2-h10-reference-library/19 | ProgressiveTestStruct | src/root.bend | the active-field chunk is padded to 31 bytes | KILLED | root_scope.bend: active_scope |  |
| r2-h10-reference-library/20 | CompatibleUnionBC | src/root.bend | the selector chunk is the selector plus one | KILLED | root_scope.bend: selector_scope |  |
| r2-h10-reference-library/21 | FuluExecutionRequests | src/root.bend | the count of a vector may be any value at most n | KILLED | root_domain_steps.bend: valid_value_correct |  |
| r2-h10-reference-library/22 | FuluExecutionRequests | src/root.bend | the list limit is strict (count < n) | KILLED | root_domain_steps.bend: valid_value_correct |  |
| r2-k01-cap-cnt/01 | bytelist_256 | src/obj.bend | the two arms of the clamp are swapped (a fitting object is hashed over w / u items) | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/02 | bytelist_256 | src/obj.bend | the clamp tests m < w (an object whose items exactly fill the storage is clamped to w / u = k: designed equivalent) | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/03 | bytelist_256 | src/obj.bend | the clamp admits objects that overrun the storage by up to one item (m <= w + u) | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/04 | bytelist_256 | src/obj.bend | an object that overruns its storage is hashed over the items the storage holds, w / u: here one more (ceil) | SURVIVED |  |  |
| r2-k01-cap-cnt/05 | bytelist_256 | src/obj.bend | an object that overruns its storage is hashed over w / u items: here w / (u + 1) | SURVIVED |  |  |
| r2-k01-cap-cnt/06 | bytelist_256 | src/obj.bend | an object that overruns its storage is hashed over w / u items: here w items (words taken for chunks) | SURVIVED |  |  |
| r2-k01-cap-cnt/07 | bytelist_256 | src/obj.bend | the object's words are 8 per chunk (m = e8(chunks)) | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/08 | bytelist_256 | src/obj.bend | a chunk is 8 words | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/09 | bytelist_256 | src/obj.bend | the root is bounded by the storage (CH-03) | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/10 | proglist_uint8 | src/obj.bend | the progressive packed-bytes root is bounded by the storage (CH-03) | KILLED | words_cap.bend: wrp_unfold |  |
| r2-k01-cap-cnt/11 | FuluDataColumnSidecar | src/obj.bend | an element sequence is bounded by the storage: m = count * ew words | KILLED | words_cap.bend: er_unfold |  |
| r2-k01-cap-cnt/12 | FuluDataColumnSidecar | src/obj.bend | an element sequence is bounded by the storage: an element is ew words | KILLED | words_cap.bend: er_unfold |  |
| r2-k01-cap-cnt/13 | FuluDataColumnSidecar | src/obj.bend | the progressive element root is bounded by the storage | SURVIVED |  |  |
| r2-k01-cap-cnt/14 | bytelist_256 | src/obj.bend | an empty data tree is the zero tree | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/15 | FuluDataColumnSidecar | src/obj.bend | an empty element sequence is the zero tree | KILLED | cells.bend: ev_st |  |
| r2-o01-first-offset/01 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the first offset may be any value at least 8 | KILLED | var_codec_AttesterSlashing.bend: st_a |  |
| r2-o01-first-offset/02 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the first offset may be any value at most 8 | KILLED | var_codec_AttesterSlashing.bend: st_a |  |
| r2-o01-first-offset/03 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the first offset check is dropped | KILLED | var_codec_AttesterSlashing.bend: st_a |  |
| r2-o01-first-offset/04 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the order test o0 <= o1 is dropped (the first element window is negative) | KILLED | var_codec_AttesterSlashing.bend: st_b |  |
| r2-o01-first-offset/05 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the bound o1 <= len is dropped | KILLED | var_codec_AttesterSlashing.bend: st_b |  |
| r2-o01-first-offset/06 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the bound is o1 < len (an empty second element is refused: it is invalid anyway) | KILLED | var_codec_AttesterSlashing.bend: st_b |  |
| r2-o01-first-offset/07 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the minimum length is 4 (the second offset is read past the end) | KILLED | var_codec_AttesterSlashing.bend: ok_eval |  |
| r2-o02-list-of-variable-first-offset/01 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the alignment test (first mod 4 = 0) is dropped | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/02 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the count limit is 9 | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/03 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the count limit is 7 | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/04 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the count limit is dropped | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/05 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the bound first <= len is dropped (the count may exceed what the input holds) | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/06 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the lower bound 4 is dropped (first offset 0: count 0 and a non-empty input is accepted) | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/07 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the alignment and bound conjunction is an or | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/08 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the empty scope is refused | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/09 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the last element's end is read one offset past (i + 3 == n selects len) | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/10 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the element is validated only when it is the first window (acc kept True afterwards) | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/11 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the accumulated validity of the earlier elements is ignored when the element is not validated (acc lost) | UNJUDGED |  |  |
| r2-o03-dfill/01 | ComplexTestStruct | types/vec_VarTestStruct_2_def_generated.bend | the default fills one element (dfill count 1) | SURVIVED |  |  |
| r2-o03-dfill/02 | ComplexTestStruct | types/vec_VarTestStruct_2_def_generated.bend | every slot is filled at index 0 (the second slot stays absent) | SURVIVED |  |  |
| r2-o03-dfill/03 | ComplexTestStruct | types/vec_VarTestStruct_2_def_generated.bend | the filler is the empty box (the absent element the CH-10 fix removed) | SURVIVED |  |  |
| r2-o03-dfill/04 | ComplexTestStruct | types/vec_VarTestStruct_2_def_generated.bend | the stored count is 1 (elements fill both slots but the count is one) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: ComplexTestStruct_mc_ser |  |
| r2-s01-bulk-copy/01 | FuluBytes96 | src/obj.bend | the last lane of a block stores to b + 6 (overwrites lane 6, lane 7 is left zero) | KILLED | arr_shift.bend: c7 |  |
| r2-s01-bulk-copy/02 | FuluBytes96 | src/obj.bend | lane 3 reads source word a + 3 instead of a + 4 (one lane repeated) | KILLED | arr_shift.bend: c3 |  |
| r2-s01-bulk-copy/03 | FuluBytes96 | src/obj.bend | the destination advances by 7 words per block | KILLED | arr_shift.bend: blk |  |
| r2-s01-bulk-copy/04 | FuluBytes96 | src/obj.bend | the tail loop advances the destination by 2 | KILLED | vbuf.bend: tail |  |
| r2-s01-bulk-copy/05 | FuluBytes48 | src/obj.bend | the tail count is nw & 3 (words 4..7 of the remainder are not copied) | KILLED | arr_shift.bend: acp |  |
| r2-s01-bulk-copy/06 | FuluBytes96 | src/obj.bend | the block count is nw / 4 | KILLED | arr_shift.bend: acp |  |
| r2-s01-bulk-copy/07 | ComplexTestStruct | src/obj.bend | offset 1 mod 4 uses the plain copy | UNJUDGED |  |  |
| r2-s01-bulk-copy/08 | ComplexTestStruct | src/obj.bend | offset 2 mod 4 uses the 24-bit shift (scopy3) | UNJUDGED |  |  |
| r2-s01-bulk-copy/09 | ComplexTestStruct | src/obj.bend | an empty range is copied as if it had a word (the empty test is n = 1) | KILLED | arr_copy.bend: read_al |  |
| r2-s01-bulk-copy/10 | ComplexTestStruct | src/obj.bend | the source word index is off >> 3 | KILLED | arr_copy.bend: read_al |  |
| r2-s01-bulk-copy/11 | ComplexTestStruct | src/obj.bend | floor(n / 4) words are copied (a partial last word is dropped) | KILLED | arr_copy.bend: read_al |  |
| r2-s01-bulk-copy/12 | ComplexTestStruct | src/obj.bend | the mask applies to the word before the last | KILLED | vcopy.bend: mask_keep |  |
| r2-s01-bulk-copy/13 | ComplexTestStruct | src/obj.bend | the tail word uses << 16 (the constant of the 2-byte shift) | KILLED | ComplexTestStruct_decode_ssz_proof_generated.bend: sc1tail |  |
| r2-s01-bulk-copy/14 | ComplexTestStruct | src/obj.bend | the tail word shifts the carry by 8 (not 16) | KILLED | ComplexTestStruct_decode_ssz_proof_generated.bend: sc2tail |  |
| r2-s01-bulk-copy/15 | ComplexTestStruct | src/obj.bend | the tail word uses << 16 | KILLED | ComplexTestStruct_decode_ssz_proof_generated.bend: sc3tail |  |
| r2-s01-bulk-copy/16 | FuluBytes96 | src/obj.bend | lane 5 uses << 8 for the high part | KILLED | vbx.bend: sc1c5 |  |
| r2-s01-bulk-copy/17 | FuluBytes96 | src/obj.bend | lane 2 reads the next source word one too far (a + 5) | KILLED | vbx.bend: sc2c2 |  |
| r2-s01-bulk-copy/18 | FuluBytes96 | src/obj.bend | lane 6 shifts the carry by 16 | KILLED | vbx.bend: sc3c6 |  |
| r2-s01-bulk-copy/19 | FuluBytes96 | src/obj.bend | the block advances the destination by 9 | KILLED | vbx.bend: sc1blk |  |
| r2-s02-unaligned-writer/01 | ComplexTestStruct | src/obj.bend | position 1 mod 4 uses the 16-bit family (pw_run2) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/02 | ComplexTestStruct | src/obj.bend | position 2 mod 4 uses the 24-bit family (pw_run3) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/03 | VarTestStruct | src/obj.bend | the carry shift is >> 16 | KILLED | VarTestStruct_encode_ssz_proof_generated.bend: pwor |  |
| r2-s02-unaligned-writer/04 | VarTestStruct | src/obj.bend | the word is shifted by 16 on the last step | KILLED | VarTestStruct_encode_ssz_proof_generated.bend: pwor |  |
| r2-s02-unaligned-writer/05 | ComplexTestStruct | src/obj.bend | the carry is >> 16 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: pwor |  |
| r2-s02-unaligned-writer/06 | ComplexTestStruct | src/obj.bend | the carry is >> 8 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: pwor |  |
| r2-s02-unaligned-writer/07 | ComplexTestStruct | src/obj.bend | the interior count is (n + s - 3) >> 2 (one word too many when n + s is 3 mod 4) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/08 | ComplexTestStruct | src/obj.bend | the short-range test is n + s <= 4 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/09 | ComplexTestStruct | src/obj.bend | the carry is skipped when it is at most 1 (a carry of exactly 1 is lost) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/10 | ComplexTestStruct | src/obj.bend | the carry lands at word q + nw - 1 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/11 | FuluBytes96 | src/obj.bend | the partial-word test is n & 3 = 1 (a 2 or 3 byte tail is stored whole and overwrites its neighbour) | KILLED | arr_copy.bend: put_al |  |
| r2-s02-unaligned-writer/12 | FuluBytes96 | src/obj.bend | it is OR-ed at word q + nw | UNJUDGED |  |  |
| r2-s02-unaligned-writer/13 | ComplexTestStruct | src/obj.bend | an empty range is written as a one-word range (the empty test is n = 1) | KILLED | arr_copy.bend: put_al |  |
| r2-s02-unaligned-writer/14 | ComplexTestStruct | src/obj.bend | the destination word is p >> 3 | KILLED | arr_copy.bend: put_al |  |
| r2-s02-unaligned-writer/15 | ComplexTestStruct | src/obj.bend | the spill constant for p = 1 mod 4 is x >> 16 | KILLED | vuwf1_bv64.bend: putu_bv64 |  |
| r2-s02-unaligned-writer/16 | ComplexTestStruct | src/obj.bend | the spill constant for p = 2 mod 4 is x >> 24 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: e2 |  |
| r2-s02-unaligned-writer/17 | ComplexTestStruct | src/obj.bend | the spill constant for p = 3 mod 4 is x >> 16 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: e2 |  |
| r2-s02-unaligned-writer/18 | ComplexTestStruct | src/obj.bend | the spill goes to word p >> 2 + 2 | KILLED | vuw.bend: w32u_rt |  |
| r2-s02-unaligned-writer/19 | ComplexTestStruct | src/obj.bend | shift by 2 bytes becomes 1 byte (x * 256) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: e1 |  |
| r2-s02-unaligned-writer/20 | ComplexTestStruct | src/obj.bend | shift by 3 bytes becomes 2 bytes | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: e1 |  |
| r2-s02-unaligned-writer/21 | ComplexTestStruct | src/obj.bend | the byte position is p mod 2 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: put_bits2 |  |
| r2-s02-unaligned-writer/22 | ComplexTestStruct | src/obj.bend | the high byte is written at p + 2 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: w16_anyW |  |
| r2-s02-unaligned-writer/23 | ComplexTestStruct | src/obj.bend | hi is stored at p + 8 | UNJUDGED |  |  |
| r2-s02-unaligned-writer/24 | ComplexTestStruct | src/obj.bend | hi goes to word + 2 | KILLED | var_fix_types.bend: put_u64W |  |
| r2-s02-unaligned-writer/25 | ComplexTestStruct | src/obj.bend | true writes the byte 2 | SURVIVED |  |  |
| r2-s03-element-access/01 | bytelist_256 | src/obj.bend | a 3-byte write uses the 2-byte mask | SURVIVED |  |  |
| r2-s03-element-access/02 | bytelist_256 | src/obj.bend | a 2-byte write uses the 1-byte mask | KILLED | encset_r_l1024_u16.bend: hw_go_0_1 |  |
| r2-s03-element-access/03 | bytelist_256 | src/obj.bend | the old word is not cleared (the new bytes are OR-ed into the old ones) | KILLED | encset_r_l1024_u16.bend: shr_merge |  |
| r2-s03-element-access/04 | bytelist_256 | src/obj.bend | the written value is not masked (a wide value spills into the neighbours) | KILLED | encset_r_l1024_u16.bend: shr_merge |  |
| r2-s03-element-access/05 | bytelist_256 | src/obj.bend | the mask is not shifted to position s | KILLED | encset_r_l1024_u16.bend: byte_go_1 |  |
| r2-s03-element-access/06 | bytelist_256 | src/obj.bend | the in-word position is p mod 2 | KILLED | encset_r_l1024_u16.bend: ww_obj |  |
| r2-s03-element-access/07 | bytelist_256 | src/obj.bend | the in-word shift is ignored (always the first byte of the word) | KILLED | encset_r_l1024_u16.bend: ba_obj |  |
| r2-s03-element-access/08 | bytelist_256 | src/obj.bend | a 3-byte read keeps 2 bytes | KILLED | vbytes.bend: keep3 |  |
| r2-s03-element-access/09 | bytelist_256 | src/obj.bend | a shift of 3 bytes is x >> 16 | KILLED | encset_r_l1024_u16.bend: byte_go_3 |  |
| r2-s03-element-access/10 | Fulu_list_uint64_128 | src/obj.bend | the pair is (hi, lo) | KILLED | coll_u64.bend: u64_read |  |
| r2-s03-element-access/11 | Fulu_list_uint64_128 | src/obj.bend | it is read two words later | KILLED | coll_u64.bend: u64_read |  |
| r2-s03-element-access/12 | Fulu_list_uint64_128 | src/obj.bend | hi is written two words later | KILLED | coll_u64.bend: u64_write |  |
| r2-s03-element-access/13 | bitlist_9 | src/obj.bend | bit i is bit i mod 16 of word i / 32 | SURVIVED |  |  |
| r2-s03-element-access/14 | bitlist_9 | src/obj.bend | the word index of the write is i / 16 | SURVIVED |  |  |
| r2-s03-element-access/15 | bitlist_9 | src/obj.bend | the bit position is i mod 16 | SURVIVED |  |  |
| r2-s03-element-access/16 | Fulu_list_bytevec_2048_4096 | src/obj.bend | the slice copies floor(n / 4) words | SURVIVED |  |  |
| r2-s03-element-access/17 | Fulu_list_bytevec_2048_4096 | src/obj.bend | it starts at word p >> 2 + 1 | KILLED | cell_rw.bend: slc_step |  |
| r2-s04-packed-validity/01 | VarTestStruct | src/obj.bend | the evenness test is n & 3 = 0 | KILLED | VarTestStruct_encode_ssz_proof_generated.bend: valid |  |
| r2-s04-packed-validity/02 | Fulu_list_uint64_128 | src/obj.bend | the divisibility test is n & 3 = 0 | KILLED | venc.bend: words_ok_u64 |  |
| r2-s04-packed-validity/03 | Fulu_list_uint64_128 | src/obj.bend | the divisibility test is n & 1 = 0 | SURVIVED |  |  |
| r2-s04-packed-validity/04 | Fulu_list_bytevec_2048_4096 | src/obj.bend | the divisibility test is n & 15 = 0 | SURVIVED |  |  |
| r2-s04-packed-validity/05 | Fulu_list_bytevec_2048_4096 | src/obj.bend | the general case tests n / unit = 0 | KILLED | spec_arr_SyncCommittee.bend: SyncCommittee_spec_bytes |  |
| r2-s04-packed-validity/06 | VarTestStruct | src/obj.bend | the lower bound is strict (n > lo) | KILLED | arr_copy.bend: vok |  |
| r2-s04-packed-validity/07 | VarTestStruct | src/obj.bend | the upper bound applies only when big (and instead of or) | KILLED | arr_copy.bend: vok |  |
| r2-s04-packed-validity/08 | VarTestStruct | src/obj.bend | the storage test is ceil(n / 4) < capacity (a full array is refused) | KILLED | arr_copy.bend: vok |  |
| r2-s04-packed-validity/09 | VarTestStruct | src/obj.bend | the storage check counts n / 4 words (floor: a partial last word may be missing) | KILLED | arr_copy.bend: vok |  |
| r2-s04-packed-validity/10 | VarTestStruct | src/obj.bend | the tail test uses n mod 2 (r = 3 is tested like r = 1) | KILLED | arr_copy.bend: vok |  |
| r2-s04-packed-validity/11 | bitlist_9 | src/obj.bend | storage is required only through word nbits >> 5 - 1 | KILLED | encx_bits6.bend: valid |  |
| r2-s04-packed-validity/12 | bitlist_9 | src/obj.bend | r is nbits mod 16 | KILLED | encx_bits6.bend: valid |  |
| r2-s04-packed-validity/13 | bitlist_9 | src/obj.bend | the limit applies only when big (and instead of or) | KILLED | vbitcont.bend: valid_eval |  |
| r2-s04-packed-validity/14 | bitvector_9 | src/obj.bend | the check reads word k >> 5 + 1 | KILLED | vuwl_bv1281.bend: valid |  |
| r2-s05-poison/01 | VarTestStruct | src/obj.bend | the poison bit is not kept (a plain sum) | KILLED | venc.bend: padd_ok |  |
| r2-s05-poison/02 | VarTestStruct | src/obj.bend | the poison test is strictly above 2^31 (exactly 2^31 is not detected) | SURVIVED |  |  |
| r2-s05-poison/03 | VarTestStruct | src/obj.bend | a false flag contributes bit 30 | SURVIVED |  |  |
| r2-s05-poison/04 | VarTestStruct | src/obj.bend | the storage test is ceil(n / 4) < capacity | KILLED | var_plist_proglist_uint256_enc.bend: encode_eval |  |
| r2-s05-poison/05 | bitlist_9 | src/obj.bend | the storage test is (k >> 5) + 1 < capacity | KILLED | var_bits_enc_bitlist_32.bend: encode_eval |  |
| r2-s05-poison/06 | VarTestStruct | src/obj.bend | the output length is m + 1 | KILLED | VarTestStruct_encode_ssz_proof_generated.bend: VarTestStruct_mc_ser |  |
| r2-v01-composite-validity/01 | FuluAttesterSlashing | types/FuluAttesterSlashing_encode_ssz_generated.bend | field attestation_1's validity is not consulted | UNJUDGED |  |  |
| r2-v01-composite-validity/02 | FuluAttesterSlashing | types/FuluAttesterSlashing_encode_ssz_generated.bend | field attestation_2's validity is not consulted | UNJUDGED |  |  |
| r2-v01-composite-validity/03 | FuluAttesterSlashing | types/FuluAttesterSlashing_encode_ssz_generated.bend | the running conjunction is an or at the last field | SURVIVED |  |  |
| r2-v01-composite-validity/04 | FuluAttesterSlashing | types/FuluAttesterSlashing_encode_ssz_generated.bend | the running conjunction is an or at the first step | SURVIVED |  |  |
| r2-v01-composite-validity/05 | FuluAttesterSlashing | types/FuluIndexedAttestation_encode_ssz_generated.bend | the validity of attesting_indices is not consulted | UNJUDGED |  |  |
| r2-v01-composite-validity/06 | FuluAttesterSlashing | types/FuluIndexedAttestation_encode_ssz_generated.bend | the field validity is or-ed with the accumulator | SURVIVED |  |  |
| r2-v02-box-absent/01 | FuluAttesterSlashing | types/FuluAttesterSlashing_encode_ssz_generated.bend | an empty box is valid | SURVIVED |  |  |
| r2-v02-box-absent/02 | FuluAttesterSlashing | types/FuluIndexedAttestation_encode_ssz_generated.bend | an empty box is valid | SURVIVED |  |  |
| r2-v02-box-absent/03 | FuluAttesterSlashing | types/FuluIndexedAttestation_encode_ssz_generated.bend | an empty box contributes no poison to the running size (the encoder writes nothing for it and reports a valid size) | KILLED | IndexedAttestation_generated.bend: IndexedAttestation_mc_bxpoison_IndexedAttestation |  |
| r2-v03-element-array-validity/01 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the storage check n <= capacity is dropped from the validity | KILLED | var_rlenc_ExecutionRequests.bend: pvl_l16_WithdrawalRequestW |  |
| r2-v03-element-array-validity/02 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the storage check is n < capacity (a full array is refused) | KILLED | var_rlenc_ExecutionRequests.bend: pvl_l16_WithdrawalRequestW |  |
| r2-v03-element-array-validity/03 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the limit check is dropped (Bool.or(True, ...)) | KILLED | var_rlenc_ExecutionRequests.bend: pvl_l16_WithdrawalRequestW |  |
| r2-v03-element-array-validity/04 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the limit check is n <= 17 | KILLED | var_rlenc_ExecutionRequests.bend: pvl_l16_WithdrawalRequestW |  |
| r2-v03-element-array-validity/05 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the size pass does not check the storage (size = n * 76 whatever the array holds) | KILLED | encx_l16_WithdrawalRequest.bend: sizex_l16_WithdrawalRequest |  |
| r2-v03-element-array-validity/06 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the size-pass storage check is n < c | KILLED | encx_l16_WithdrawalRequest.bend: sizex_l16_WithdrawalRequest |  |
| r2-v03-element-array-validity/07 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the running size reported by putn is 75 n | KILLED | var_rlenc_ExecutionRequests.bend: pvl_l16_WithdrawalRequestW |  |
| r2-v03-element-array-validity/08 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the intermediate elements are written at pos + 75 i | KILLED | var_rlenc_ExecutionRequests.bend: ptl_l16_WithdrawalRequestW |  |
| r2-v04-group-validity/01 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the group g2 step keeps only the last group's validity (the running conjunction is replaced by ok) | SURVIVED |  |  |
| r2-v04-group-validity/02 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the final step ignores the last group (acc only) | SURVIVED |  |  |
| r2-v04-group-validity/03 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the validity of group g0 is not carried into the conjunction (acc dropped at the second step) | SURVIVED |  |  |
| r2-v04-group-validity/04 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the validity of group g1 (extra_data, transactions, withdrawals) is not consulted | UNJUDGED |  |  |
| r2-v04-group-validity/05 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the validity of group g0 (logs_bloom) is not consulted | UNJUDGED |  |  |
| r2-v04-group-validity/07 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the validity of the transactions list is not consulted | UNJUDGED |  |  |
| r2-v04-group-validity/08 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the validity of the withdrawals list is not consulted | UNJUDGED |  |  |
| r2-v04-group-validity/09 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the last field's validity is combined with the accumulator by or | SURVIVED |  |  |
| r2-v04-group-validity/10 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the logs_bloom validity is combined with the accumulator by or | SURVIVED |  |  |
| r2-v05-attestation/01 | FuluAttestation | types/FuluAttestation_encode_ssz_generated.bend | the validity of aggregation_bits (the only checked field of Attestation) is not consulted | UNJUDGED |  |  |
| r2-v05-attestation/02 | FuluAttestation | types/FuluAttestation_encode_ssz_generated.bend | the field validity is or-ed with the accumulator | SURVIVED |  |  |
| r2-v06-composite-list-validity/01 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | an element's validity is combined with all earlier ones (conjunction) | SURVIVED |  |  |
| r2-v06-composite-list-validity/02 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | an element's validity is combined with all earlier ones (conjunction) | SURVIVED |  |  |
| r2-v06-composite-list-validity/03 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | every one of the n elements is checked | KILLED | encx_l1048576_bl1073741824.bend: valid_l |  |
| r2-v06-composite-list-validity/04 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | the list is valid iff the loop result is valid | SURVIVED |  |  |
| r2-v06-composite-list-validity/05 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | the count may not exceed the storage | KILLED | encx_l1048576_bl1073741824.bend: valid_l |  |
| r2-v06-composite-list-validity/06 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | List[Transaction, 1048576] holds at most 1048576 transactions | KILLED | encx_l1048576_bl1073741824.bend: valid_l |  |
| r2-v06-composite-list-validity/07 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | an element is validated in place (swapped out and set back) | KILLED | encx_l1048576_bl1073741824.bend: va_go |  |
