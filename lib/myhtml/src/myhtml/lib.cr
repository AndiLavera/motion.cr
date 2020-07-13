require "./lib/*"

module Myhtml
  # Static library builded by `shards install`, or by `make` in project root
  @[Link(ldflags: "#{__DIR__}/../ext/modest-c/lib/libmodest_static.a")]
  lib Lib
    # MYHTML API
    # https://github.com/lexborisov/myhtml/blob/master/include/myhtml/api.h

    type MyhtmlT = Void*
    type MyhtmlTreeT = Void*
    type MyhtmlTreeNodeT = Void*
    type MyhtmlTreeAttrT = Void*
    type MyhtmlTagIndexT = Void*
    type MyhtmlTagIndexNodeT = Void*
    alias MyhtmlTagIdT = MyhtmlTags
    type MycoreCallbackSerializeT = (UInt8*, LibC::SizeT, Void*) -> MyStatus

    struct MyhtmlVersion
      major : Int32
      minor : Int32
      patch : Int32
    end

    struct MyhtmlStringRawT
      data : UInt8*
      size : LibC::SizeT
      length : LibC::SizeT
    end

    struct MyhtmlCollectionT
      list : MyhtmlTreeNodeT**
      size : LibC::SizeT
      length : LibC::SizeT
    end

    fun version = myhtml_version : MyhtmlVersion

    # Creation methods
    fun create = myhtml_create : MyhtmlT*
    fun init = myhtml_init(myhtml : MyhtmlT*, opt : MyhtmlOptions, thread_count : LibC::SizeT, queue_size : LibC::SizeT) : MyStatus
    fun tree_create = myhtml_tree_create : MyhtmlTreeT*
    fun tree_init = myhtml_tree_init(tree : MyhtmlTreeT*, myhtml : MyhtmlT*) : MyStatus
    fun tree_destroy = myhtml_tree_destroy(tree : MyhtmlTreeT*) : MyhtmlTreeT*
    fun node_create = myhtml_node_create(
      tree : MyhtmlTreeT*,
      tag_id : MyhtmlTagIdT,
      ns : MyhtmlNamespace
    ) : MyhtmlTreeNodeT*
    fun destroy = myhtml_destroy(myhtml : MyhtmlT*) : MyhtmlT*

    # Parse methods
    fun parse = myhtml_parse(tree : MyhtmlTreeT*, encoding : MyEncodingList, html : UInt8*, html_size : LibC::SizeT) : MyStatus
    fun parse_chunk = myhtml_parse_chunk(tree : MyhtmlTreeT*, html : UInt8*, html_size : LibC::SizeT) : MyStatus
    fun parse_chunk_end = myhtml_parse_chunk_end(tree : MyhtmlTreeT*) : MyStatus
    fun tree_parse_flags_set = myhtml_tree_parse_flags_set(tree : MyhtmlTreeT*, parse_flags : MyhtmlTreeParseFlags)

    # Encoding methods
    fun encoding_detect_and_cut_bom = myencoding_detect_and_cut_bom(text : UInt8*, length : LibC::SizeT, encoding : MyEncodingList*, new_text : UInt8**, new_size : LibC::SizeT*) : Bool
    fun encoding_set = myhtml_encoding_set(tree : MyhtmlTreeT*, encoding : MyEncodingList)
    fun encoding_prescan_stream_to_determine_encoding = myencoding_prescan_stream_to_determine_encoding(data : UInt8*, data_size : LibC::SizeT) : MyEncodingList
    fun encoding_prescan_stream_to_determine_encoding_with_found = myencoding_prescan_stream_to_determine_encoding_with_found(data : UInt8*, data_size : LibC::SizeT, found : UInt8**, found_length : LibC::SizeT*) : MyEncodingList
    fun encoding_name_by_id = myencoding_name_by_id(encoding : MyEncodingList, length : LibC::SizeT*) : UInt8*
    fun encoding_extracting_character_encoding_from_charset = myencoding_extracting_character_encoding_from_charset(data : UInt8*, data_size : LibC::SizeT, encoding : MyEncodingList*) : Bool
    fun encoding_extracting_character_encoding_from_charset_with_found = myencoding_extracting_character_encoding_from_charset_with_found(data : UInt8*, data_size : LibC::SizeT, encoding : MyEncodingList*, found : UInt8**, found_length : LibC::SizeT*) : Bool
    fun encoding_detect = myencoding_detect(text : UInt8*, length : LibC::SizeT, encoding : MyEncodingList*) : Bool

    # Root nodes
    fun tree_get_document = myhtml_tree_get_document(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_html = myhtml_tree_get_node_html(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_head = myhtml_tree_get_node_head(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_body = myhtml_tree_get_node_body(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*

    # Node info
    fun node_tag_id = myhtml_node_tag_id(node : MyhtmlTreeNodeT*) : MyhtmlTagIdT
    fun tag_name_by_id = myhtml_tag_name_by_id(tree : MyhtmlTreeT*, tag_id : MyhtmlTagIdT, length : LibC::SizeT*) : UInt8*
    fun node_text = myhtml_node_text(node : MyhtmlTreeNodeT*, length : LibC::SizeT*) : UInt8*
    fun node_text_set_with_charef = myhtml_node_text_set_with_charef(node : MyhtmlTreeNodeT*, text : UInt8*, length : LibC::SizeT, encoding : MyEncodingList)
    fun node_is_close_self = myhtml_node_is_close_self(node : MyhtmlTreeNodeT*) : Bool
    fun node_is_void_element = myhtml_node_is_void_element(node : MyhtmlTreeNodeT*) : Bool

    # Navigation methods
    fun node_child = myhtml_node_child(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_next = myhtml_node_next(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_parent = myhtml_node_parent(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_prev = myhtml_node_prev(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_last_child = myhtml_node_last_child(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*

    # Data methods
    fun node_set_data = myhtml_node_set_data(node : MyhtmlTreeNodeT*, data : Void*)
    fun node_get_data = myhtml_node_get_data(node : MyhtmlTreeNodeT*) : Void*

    # Attribute methods
    fun node_attribute_first = myhtml_node_attribute_first(node : MyhtmlTreeNodeT*) : MyhtmlTreeAttrT*
    fun attribute_next = myhtml_attribute_next(attr : MyhtmlTreeAttrT*) : MyhtmlTreeAttrT*
    fun attribute_key = myhtml_attribute_key(attr : MyhtmlTreeAttrT*, length : LibC::SizeT*) : UInt8*
    fun attribute_value = myhtml_attribute_value(attr : MyhtmlTreeAttrT*, length : LibC::SizeT*) : UInt8*
    fun attribute_add = myhtml_attribute_add(node : MyhtmlTreeNodeT*, key : LibC::Char*, key_len : LibC::SizeT, value : LibC::Char*, value_len : LibC::SizeT, encoding : MyEncodingList) : MyhtmlTreeAttrT*
    fun attribute_remove_by_key = myhtml_attribute_remove_by_key(node : MyhtmlTreeNodeT*, key : LibC::Char*, key_len : LibC::SizeT) : MyhtmlTreeAttrT*

    # Serialize methods
    fun serialization = myhtml_serialization(node : MyhtmlTreeNodeT*, str : MyhtmlStringRawT*) : MyStatus
    fun serialization_node = myhtml_serialization_node(node : MyhtmlTreeNodeT*, str : MyhtmlStringRawT*) : MyStatus
    fun serialization_tree_callback = myhtml_serialization_tree_callback(node : MyhtmlTreeNodeT*, callback : MycoreCallbackSerializeT, data : Void*) : MyStatus
    fun serialization_node_callback = myhtml_serialization_node_callback(node : MyhtmlTreeNodeT*, callback : MycoreCallbackSerializeT, data : Void*) : MyStatus

    # Util methods
    fun string_raw_clean_all = mycore_string_raw_clean_all(str_raw : MyhtmlStringRawT*)
    fun string_raw_destroy = mycore_string_raw_destroy(str_raw : MyhtmlStringRawT*, destroy_obj : Bool) : MyhtmlStringRawT*

    # Filter methods
    fun get_nodes_by_tag_id = myhtml_get_nodes_by_tag_id(tree : MyhtmlTreeT*, collection : MyhtmlCollectionT*, tag_id : MyhtmlTagIdT, status : MyStatus*) : MyhtmlCollectionT*
    fun collection_destroy = myhtml_collection_destroy(collection : MyhtmlCollectionT*) : MyhtmlCollectionT*

    # Tree mutation
    fun tree_node_add_child = myhtml_tree_node_add_child(
      root : MyhtmlTreeNodeT*,
      node : MyhtmlTreeNodeT*
    )
    fun tree_node_insert_before = myhtml_tree_node_insert_before(
      root : MyhtmlTreeNodeT*,
      node : MyhtmlTreeNodeT*
    )
    fun tree_node_insert_after = myhtml_tree_node_insert_after(
      root : MyhtmlTreeNodeT*,
      node : MyhtmlTreeNodeT*
    )
    fun node_remove = myhtml_node_remove(node : MyhtmlTreeNodeT*)

    # FOR SAX Parsing
    type MyhtmlTokenNodeT = Void*
    type MyhtmlCallbackTokenF = MyhtmlTreeT*, MyhtmlTokenNodeT*, Void* -> Void*
    type MyhtmlIncomingBufferT = Void*

    struct MyhtmlPositionT
      start : LibC::SizeT
      length : LibC::SizeT
    end

    fun callback_before_token_done_set = myhtml_callback_before_token_done_set(tree : MyhtmlTreeT*, func : MyhtmlCallbackTokenF, ctx : Void*)
    fun callback_after_token_done_set = myhtml_callback_after_token_done_set(tree : MyhtmlTreeT*, func : MyhtmlCallbackTokenF, ctx : Void*)
    fun tree_incoming_buffer_first = myhtml_tree_incoming_buffer_first(tree : MyhtmlTreeT*) : MyhtmlIncomingBufferT*

    fun token_node_raw_position = myhtml_token_node_raw_position(token : MyhtmlTokenNodeT*) : MyhtmlPositionT
    fun token_node_element_position = myhtml_token_node_element_position(token : MyhtmlTokenNodeT*) : MyhtmlPositionT
    fun token_node_attribute_first = myhtml_token_node_attribute_first(token : MyhtmlTokenNodeT*) : MyhtmlTreeAttrT*
    fun token_node_tag_id = myhtml_token_node_tag_id(token : MyhtmlTokenNodeT*) : MyhtmlTagIdT
    fun token_node_text = myhtml_token_node_text(node : MyhtmlTokenNodeT*, length : LibC::SizeT*) : UInt8*
    fun token_node_is_close_self = myhtml_token_node_is_close_self(token : MyhtmlTokenNodeT*) : Bool
    fun token_node_is_close = myhtml_token_node_is_close(token : MyhtmlTokenNodeT*) : Bool

    fun incoming_buffer_find_by_position = mycore_incoming_buffer_find_by_position(inc_buf : MyhtmlIncomingBufferT*, begin : LibC::SizeT) : MyhtmlIncomingBufferT*
    fun incoming_buffer_offset = mycore_incoming_buffer_offset(inc_buf : MyhtmlIncomingBufferT*) : LibC::SizeT
    fun incoming_buffer_data = mycore_incoming_buffer_data(inc_buf : MyhtmlIncomingBufferT*) : UInt8*

    fun attribute_key_raw_position = myhtml_attribute_key_raw_position(attr : MyhtmlTreeAttrT*) : MyhtmlPositionT
    fun attribute_value_raw_position = myhtml_attribute_value_raw_position(attr : MyhtmlTreeAttrT*) : MyhtmlPositionT
  end
end
