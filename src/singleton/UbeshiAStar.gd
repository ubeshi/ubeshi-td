extends Node

class PointTranslation:
    var x_offset: int;
    var y_offset: int;
    var cell_size: int = 64;

    func _init(p_x_offset: int, p_y_offset: int, p_cell_size: int = 64):
        self.x_offset = p_x_offset;
        self.y_offset = p_y_offset;
        self.cell_size = p_cell_size;

func get_new_map(width: int, height: int, point_translation: PointTranslation) -> AStar:
    var a_star = AStar.new();
    add_map_points(a_star, width, height, point_translation);
    connect_map_points(a_star, width, height);

    return a_star;

func add_map_points(a_star: AStar, width: int, height: int, point_translation: PointTranslation) -> void:
    for y_position in range(0, height):
        add_map_points_row(a_star, width, y_position, point_translation);

func add_map_points_row(a_star: AStar, width: int, y_position: int, point_translation: PointTranslation) -> void:
    var point_id = width * y_position;
    var cell_center_offset = 0.5 * point_translation.cell_size;
    for x_position in range(0, width):
        var translated_x = (x_position + point_translation.x_offset) * point_translation.cell_size + cell_center_offset;
        var translated_y = (y_position + point_translation.y_offset) * point_translation.cell_size + cell_center_offset;
        a_star.add_point(point_id, Vector3(translated_x, translated_y, 0));
        point_id += 1;

func connect_map_points(a_star: AStar, width: int, height: int) -> void:
    # Connect first row points (ids 0 to width-1)
    for point_id in range(0, width-1):
        a_star.connect_points(point_id, point_id+1);

    # Connect other row's points
    for point_id in range(width, (width*height)-1):
        # Connect row-wise adjacent points
        a_star.connect_points(point_id, point_id+1);
        # Connect column-wise adjacent points in previous row
        a_star.connect_points(point_id, point_id-width);

func get_pool_vector2_array(a_star: AStar, from_point_id: int, to_point_id: int) -> PoolVector2Array:
    var array = [];
    var point_path = a_star.get_point_path(from_point_id, to_point_id);
    for vector3 in point_path:
        var vector2 = Vector2(vector3.x, vector3.y);
        array.append(vector2);

    return array;

func replace_path_2d_points_with_vector2_array(path_2d: Path2D, array: PoolVector2Array) -> void:
    path_2d.curve.clear_points();
    for point in array:
        path_2d.curve.add_point(point);
