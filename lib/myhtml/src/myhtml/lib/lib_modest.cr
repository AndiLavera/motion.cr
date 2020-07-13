module Myhtml
  lib LibModest
    enum ModestStatusT
      MODEST_STATUS_OK                      = 0x000000
      MODEST_STATUS_ERROR                   = 0x020000
      MODEST_STATUS_ERROR_MEMORY_ALLOCATION = 0x020001
    end

    type ModestFinderT = Void*

    fun finder_create_simple = modest_finder_create_simple : ModestFinderT*
    fun finder_destroy = modest_finder_destroy(finder : ModestFinderT*, self_destroy : Bool) : ModestFinderT*
    fun finder_by_selectors_list = modest_finder_by_selectors_list(finder : ModestFinderT*,
                                                                   scope_node : Myhtml::Lib::MyhtmlTreeNodeT*,
                                                                   sel_list : LibMyCss::MycssSelectorsListT*,
                                                                   collection : Myhtml::Lib::MyhtmlCollectionT**) : ModestStatusT
  end
end
