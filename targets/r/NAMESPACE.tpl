@config banner = # @generated from schema/ntgcalls.ntl -- DO NOT EDIT
@out @{config.self_dir}/NAMESPACE
useDynLib(ntgcalls, .registration = TRUE)
export(ntgcalls)
export(NTgCallsClient)
export(EventRegistry)
@for e in enums
@if e.emit
export(@{e.name})
@end
@end
@for s in structs
export(@{s.name|snake})
@end
