%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import deploy
from starkware.cairo.common.alloc import alloc

@storage_var
func salt() -> (salt : felt):
end

@storage_var
func erc721_class_hash() -> (class_hash : felt):
end

@event
func erc721_contract_deployed(contract_address : felt):
end

@constructor
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(erc721_class_hash_ : felt):
    erc721_class_hash.write(value=erc721_class_hash_)
    return ()
end

@external
func deploy_erc721_contract{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(
    name : felt,
    symbol : felt,
    owner : felt
):
    let (current_salt) = salt.read()
    let (class_hash) = erc721_class_hash.read()
    let (constructor_args : felt*) = alloc()
    assert constructor_args[0] = name
    assert constructor_args[1] = symbol
    assert constructor_args[2] = owner

    let (contract_address) = deploy(
        class_hash=class_hash,
        contract_address_salt=current_salt,
        constructor_calldata_size=3,
        constructor_calldata=constructor_args,
        deploy_from_zero=0,
    )
    salt.write(value=current_salt + 1)
    erc721_contract_deployed.emit(contract_address=contract_address)
    return()
end