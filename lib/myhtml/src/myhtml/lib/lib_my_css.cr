module Myhtml
  lib LibMyCss
    enum MycssStatusT
      MyCSS_STATUS_OK                                     = 0x000000
      MyCSS_STATUS_ERROR_MEMORY_ALLOCATION                = 0x010001
      MyCSS_STATUS_ERROR_TOKENIZER_STATE_ALLOCATION       = 0x010020
      MyCSS_STATUS_ERROR_TOKENIZER_INCOMING_BUFFER_ADD    = 0x010021
      MyCSS_STATUS_ERROR_TOKENIZER_TOKEN_ALLOCATION       = 0x010022
      MyCSS_STATUS_ERROR_INCOMING_BUFFER_INIT             = 0x010030
      MyCSS_STATUS_ERROR_ENTRY_INCOMING_BUFFER_CREATE     = 0x010039
      MyCSS_STATUS_ERROR_ENTRY_INCOMING_BUFFER_INIT       = 0x010040
      MyCSS_STATUS_ERROR_ENTRY_TOKEN_INCOMING_BUFFER_INIT = 0x010041
      MyCSS_STATUS_ERROR_ENTRY_TOKEN_NODE_ADD             = 0x010042
      MyCSS_STATUS_ERROR_SELECTORS_CREATE                 = 0x010100
      MyCSS_STATUS_ERROR_SELECTORS_ENTRIES_CREATE         = 0x010101
      MyCSS_STATUS_ERROR_SELECTORS_ENTRIES_INIT           = 0x010102
      MyCSS_STATUS_ERROR_SELECTORS_ENTRIES_NODE_ADD       = 0x010103
      MyCSS_STATUS_ERROR_SELECTORS_LIST_CREATE            = 0x010104
      MyCSS_STATUS_ERROR_SELECTORS_LIST_INIT              = 0x010105
      MyCSS_STATUS_ERROR_SELECTORS_LIST_ADD_NODE          = 0x010106
      MyCSS_STATUS_ERROR_NAMESPACE_CREATE                 = 0x010200
      MyCSS_STATUS_ERROR_NAMESPACE_INIT                   = 0x010201
      MyCSS_STATUS_ERROR_NAMESPACE_ENTRIES_CREATE         = 0x010202
      MyCSS_STATUS_ERROR_NAMESPACE_ENTRIES_INIT           = 0x010203
      MyCSS_STATUS_ERROR_NAMESPACE_NODE_ADD               = 0x010204
      MyCSS_STATUS_ERROR_MEDIA_CREATE                     = 0x010404
      MyCSS_STATUS_ERROR_STRING_CREATE                    = 0x010501
      MyCSS_STATUS_ERROR_STRING_INIT                      = 0x010502
      MyCSS_STATUS_ERROR_STRING_NODE_INIT                 = 0x010503
      MyCSS_STATUS_ERROR_AN_PLUS_B_CREATE                 = 0x010600
      MyCSS_STATUS_ERROR_AN_PLUS_B_INIT                   = 0x010601
      MyCSS_STATUS_ERROR_DECLARATION_CREATE               = 0x010700
      MyCSS_STATUS_ERROR_DECLARATION_INIT                 = 0x010701
      MyCSS_STATUS_ERROR_DECLARATION_ENTRY_CREATE         = 0x010702
      MyCSS_STATUS_ERROR_DECLARATION_ENTRY_INIT           = 0x010703
      MyCSS_STATUS_ERROR_PARSER_LIST_CREATE               = 0x010800
    end

    type MycssT = Void*
    type MycssEntryT = Void*
    type MycssSelectorsListT = Void*
    type MycssSelectorsT = Void*

    fun create = mycss_create : MycssT*
    fun init = mycss_init(mycss : MycssT*) : MycssStatusT
    fun entry_create = mycss_entry_create : MycssEntryT*
    fun entry_init = mycss_entry_init(mycss : MycssT*, entry : MycssEntryT*) : MycssStatusT
    fun selectors_parse = mycss_selectors_parse(selectors : MycssSelectorsT*, encoding : Myhtml::Lib::MyEncodingList,
                                                data : UInt8*, data_size : LibC::SizeT, out_status : MycssStatusT*) : MycssSelectorsListT*
    fun selectors_list_destroy = mycss_selectors_list_destroy(selectors : MycssSelectorsT*, selector_list : MycssSelectorsListT*, self_destroy : Bool) : MycssSelectorsListT*

    fun entry_selectors = mycss_entry_selectors(entry : MycssEntryT*) : MycssSelectorsT*
    fun destroy = mycss_destroy(mycss : MycssT*, self_destroy : Bool) : MycssT*
    fun entry_destroy = mycss_entry_destroy(entry : MycssEntryT*, self_destroy : Bool) : MycssEntryT*
  end
end
