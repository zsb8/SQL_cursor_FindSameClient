create or replace function add_remark_arry() returns text
    language plpgsql
as
$$
declare
    curs refcursor;
    x record;
    y record;
    m text[];
    n text[];
    index int :=1;
    temp_array text[];
    root_id_array text[];
    myroot text;
    index2 int :=0;

begin
    loop
        index2 = index2 + 1;
        raise notice '====%', index2;


        open curs for select root_id, agg from parent_order_tmp where remark_array is null order by root_id;
        fetch curs into x;  raise notice 'cursor is  %', x.agg;
        temp_array := x.agg;
        root_id_array := array[x.root_id];
        loop
            index := index+1;
            fetch relative 1 from curs into y; raise notice '% , cursor is  %', index, y.agg;
            if temp_array && y.agg then
                m := array_cat(temp_array, y.agg); 
                n := ARRAY(SELECT DISTINCT e FROM unnest(m) AS a(e));  
                temp_array := n;
                root_id_array := array_append(root_id_array,y.root_id);  
            else
                raise notice 'not combine';
            end if;
            exit when not found; 
        end loop;
        FOREACH myroot IN ARRAY root_id_array LOOP
            update parent_order_tmp set remark_array=temp_array  where root_id=myroot;
            raise notice 'root_id is %, changed to %', myroot, temp_array;
        end loop;
        close curs;  
        if x.root_id is null then
            exit;
        end if;
    end loop;
    return 'ok';
end;
$$;
